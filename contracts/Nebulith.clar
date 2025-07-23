;; Nebulith - Decentralized Voting in the Cosmic DAO
;; A permissionless DAO framework enabling decentralized governance via token-weighted voting

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROPOSAL_NOT_FOUND (err u101))
(define-constant ERR_VOTING_PERIOD_ENDED (err u102))
(define-constant ERR_VOTING_PERIOD_NOT_STARTED (err u103))
(define-constant ERR_ALREADY_VOTED (err u104))
(define-constant ERR_INSUFFICIENT_TOKENS (err u105))
(define-constant ERR_PROPOSAL_NOT_ACTIVE (err u106))
(define-constant ERR_QUORUM_NOT_MET (err u107))
(define-constant ERR_INVALID_PROPOSAL (err u108))
(define-constant ERR_VOTING_DELAY_NOT_PASSED (err u109))

;; Data Variables
(define-data-var next-proposal-id uint u1)
(define-data-var quorum-threshold uint u1000000) ;; 1M tokens required for quorum
(define-data-var voting-delay uint u144) ;; ~1 day in blocks
(define-data-var voting-period uint u1008) ;; ~1 week in blocks
(define-data-var proposal-threshold uint u100000) ;; 100k tokens to create proposal

;; Proposal States
(define-constant PROPOSAL_PENDING u0)
(define-constant PROPOSAL_ACTIVE u1)
(define-constant PROPOSAL_SUCCEEDED u2)
(define-constant PROPOSAL_DEFEATED u3)
(define-constant PROPOSAL_EXECUTED u4)
(define-constant PROPOSAL_VETOED u5)

;; Data Maps
(define-map proposals
    { proposal-id: uint }
    {
        proposer: principal,
        title: (string-ascii 100),
        description: (string-ascii 500),
        start-block: uint,
        end-block: uint,
        for-votes: uint,
        against-votes: uint,
        abstain-votes: uint,
        state: uint,
        executed: bool
    }
)

(define-map votes
    { proposal-id: uint, voter: principal }
    { support: uint, weight: uint, voted-at: uint }
)

(define-map voter-power
    { voter: principal }
    { power: uint, delegated-to: (optional principal) }
)

(define-map delegation-power
    { delegate: principal }
    { total-delegated: uint }
)

;; Governance token trait (SIP-010 compatible)
(define-trait governance-token-trait
    (
        (transfer (uint principal principal (optional (buff 34))) (response bool uint))
        (get-name () (response (string-ascii 32) uint))
        (get-symbol () (response (string-ascii 10) uint))
        (get-decimals () (response uint uint))
        (get-balance (principal) (response uint uint))
        (get-total-supply () (response uint uint))
        (get-token-uri () (response (optional (string-utf8 256)) uint))
    )
)

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-voter-power (voter principal))
    (default-to { power: u0, delegated-to: none }
        (map-get? voter-power { voter: voter }))
)

(define-read-only (get-delegation-power (delegate principal))
    (default-to { total-delegated: u0 }
        (map-get? delegation-power { delegate: delegate }))
)

(define-read-only (get-proposal-state (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (get state proposal)
        u0
    )
)

(define-read-only (get-voting-power (voter principal))
    (let ((voter-data (get-voter-power voter)))
        (+ (get power voter-data)
           (get total-delegated (get-delegation-power voter))))
)

(define-read-only (has-voted (proposal-id uint) (voter principal))
    (is-some (get-vote proposal-id voter))
)

(define-read-only (get-quorum-votes (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (+ (+ (get for-votes proposal) (get against-votes proposal))
                   (get abstain-votes proposal))
        u0
    )
)

(define-read-only (proposal-succeeded (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (and (>= (get-quorum-votes proposal-id) (var-get quorum-threshold))
                     (> (get for-votes proposal) (get against-votes proposal)))
        false
    )
)

;; Private functions
(define-private (get-effective-voting-power (voter principal))
    (let ((voter-data (get-voter-power voter)))
        (match (get delegated-to voter-data)
            delegate u0  ;; If delegated, voter has no direct power
            (get-voting-power voter)  ;; Otherwise, use full voting power
        )
    )
)

(define-private (update-proposal-state (proposal-id uint))
    (let ((current-block stacks-block-height)
          (proposal-data (unwrap! (get-proposal proposal-id) (err ERR_PROPOSAL_NOT_FOUND))))
        (if (< current-block (get start-block proposal-data))
            (ok PROPOSAL_PENDING)
            (if (< current-block (get end-block proposal-data))
                (ok PROPOSAL_ACTIVE)
                (if (proposal-succeeded proposal-id)
                    (begin
                        (map-set proposals { proposal-id: proposal-id }
                            (merge proposal-data { state: PROPOSAL_SUCCEEDED }))
                        (ok PROPOSAL_SUCCEEDED))
                    (begin
                        (map-set proposals { proposal-id: proposal-id }
                            (merge proposal-data { state: PROPOSAL_DEFEATED }))
                        (ok PROPOSAL_DEFEATED))))))
)

;; Public functions
(define-public (create-proposal 
    (title (string-ascii 100))
    (description (string-ascii 500)))
    (let ((proposal-id (var-get next-proposal-id))
          (start-block (+ stacks-block-height (var-get voting-delay)))
          (end-block (+ start-block (var-get voting-period)))
          (proposer-power (get-effective-voting-power tx-sender)))
        
        ;; Validate proposer has minimum tokens
        (asserts! (>= proposer-power (var-get proposal-threshold)) ERR_INSUFFICIENT_TOKENS)
        
        ;; Validate inputs
        (asserts! (> (len title) u0) ERR_INVALID_PROPOSAL)
        (asserts! (> (len description) u0) ERR_INVALID_PROPOSAL)
        
        ;; Create proposal
        (map-set proposals { proposal-id: proposal-id }
            {
                proposer: tx-sender,
                title: title,
                description: description,
                start-block: start-block,
                end-block: end-block,
                for-votes: u0,
                against-votes: u0,
                abstain-votes: u0,
                state: PROPOSAL_PENDING,
                executed: false
            })
        
        ;; Increment proposal counter
        (var-set next-proposal-id (+ proposal-id u1))
        
        (ok proposal-id)
    )
)

(define-public (cast-vote (proposal-id uint) (support uint) (voting-power uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (available-power (get-effective-voting-power tx-sender))
          (current-block stacks-block-height))
        
        ;; Validate voting period
        (asserts! (>= current-block (get start-block proposal-data)) ERR_VOTING_PERIOD_NOT_STARTED)
        (asserts! (< current-block (get end-block proposal-data)) ERR_VOTING_PERIOD_ENDED)
        
        ;; Validate voter hasn't voted
        (asserts! (not (has-voted proposal-id tx-sender)) ERR_ALREADY_VOTED)
        
        ;; Validate voting power
        (asserts! (>= available-power voting-power) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> voting-power u0) ERR_INSUFFICIENT_TOKENS)
        
        ;; Validate support value (0=against, 1=for, 2=abstain)
        (asserts! (<= support u2) ERR_INVALID_PROPOSAL)
        
        ;; Record vote
        (map-set votes { proposal-id: proposal-id, voter: tx-sender }
            { support: support, weight: voting-power, voted-at: current-block })
        
        ;; Update proposal vote counts
        (let ((updated-proposal
                (if (is-eq support u0)
                    (merge proposal-data { against-votes: (+ (get against-votes proposal-data) voting-power) })
                    (if (is-eq support u1)
                        (merge proposal-data { for-votes: (+ (get for-votes proposal-data) voting-power) })
                        (merge proposal-data { abstain-votes: (+ (get abstain-votes proposal-data) voting-power) })))))
            (map-set proposals { proposal-id: proposal-id } updated-proposal))
        
        (ok true)
    )
)

(define-public (delegate-votes (delegate-to principal) (power uint))
    (let ((current-power (get power (get-voter-power tx-sender)))
          (current-delegation (get total-delegated (get-delegation-power delegate-to))))
        
        ;; Validate delegation power
        (asserts! (>= current-power power) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> power u0) ERR_INSUFFICIENT_TOKENS)
        (asserts! (not (is-eq tx-sender delegate-to)) ERR_UNAUTHORIZED)
        
        ;; Update delegator's power
        (map-set voter-power { voter: tx-sender }
            { power: (- current-power power), delegated-to: (some delegate-to) })
        
        ;; Update delegate's power
        (map-set delegation-power { delegate: delegate-to }
            { total-delegated: (+ current-delegation power) })
        
        (ok true)
    )
)

(define-public (revoke-delegation (delegate-from principal) (power uint))
    (let ((voter-data (get-voter-power tx-sender))
          (current-delegation (get total-delegated (get-delegation-power delegate-from))))
        
        ;; Validate caller has delegated to this delegate
        (asserts! (is-eq (get delegated-to voter-data) (some delegate-from)) ERR_UNAUTHORIZED)
        (asserts! (>= current-delegation power) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> power u0) ERR_INSUFFICIENT_TOKENS)
        
        ;; Update voter's power
        (map-set voter-power { voter: tx-sender }
            { power: (+ (get power voter-data) power), delegated-to: none })
        
        ;; Update delegate's power
        (map-set delegation-power { delegate: delegate-from }
            { total-delegated: (- current-delegation power) })
        
        (ok true)
    )
)

(define-public (set-initial-voting-power (voter principal) (power uint))
    (begin
        ;; Only contract owner can set initial voting power
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        
        ;; Validate voter principal is not contract owner (prevent self-manipulation)
        (asserts! (not (is-eq voter CONTRACT_OWNER)) ERR_UNAUTHORIZED)
        
        ;; Validate power amount
        (asserts! (> power u0) ERR_INSUFFICIENT_TOKENS)
        (asserts! (<= power u1000000000000) ERR_INSUFFICIENT_TOKENS) ;; Max reasonable power
        
        (map-set voter-power { voter: voter }
            { power: power, delegated-to: none })
        
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (current-state (unwrap! (update-proposal-state proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        ;; Validate proposal can be executed
        (asserts! (is-eq current-state PROPOSAL_SUCCEEDED) ERR_PROPOSAL_NOT_ACTIVE)
        (asserts! (not (get executed proposal-data)) ERR_PROPOSAL_NOT_ACTIVE)
        
        ;; Mark as executed
        (map-set proposals { proposal-id: proposal-id }
            (merge proposal-data { executed: true, state: PROPOSAL_EXECUTED }))
        
        (ok true)
    )
)

(define-public (veto-proposal (proposal-id uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        ;; Only contract owner can veto (could be modified for guardian role)
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        
        ;; Validate proposal exists and can be vetoed
        (asserts! (> proposal-id u0) ERR_INVALID_PROPOSAL)
        (asserts! (< proposal-id (var-get next-proposal-id)) ERR_PROPOSAL_NOT_FOUND)
        (asserts! (not (is-eq (get state proposal-data) PROPOSAL_EXECUTED)) ERR_PROPOSAL_NOT_ACTIVE)
        (asserts! (not (is-eq (get state proposal-data) PROPOSAL_VETOED)) ERR_PROPOSAL_NOT_ACTIVE)
        
        ;; Mark as vetoed
        (map-set proposals { proposal-id: proposal-id }
            (merge proposal-data { state: PROPOSAL_VETOED }))
        
        (ok true)
    )
)

;; Admin functions
(define-public (set-quorum-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-threshold u0) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-threshold u1000000000000) ERR_INVALID_PROPOSAL) ;; Max reasonable threshold
        (var-set quorum-threshold new-threshold)
        (ok true)
    )
)

(define-public (set-voting-delay (new-delay uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (>= new-delay u1) ERR_INVALID_PROPOSAL) ;; Min 1 block delay
        (asserts! (<= new-delay u2016) ERR_INVALID_PROPOSAL) ;; Max 2 weeks
        (var-set voting-delay new-delay)
        (ok true)
    )
)

(define-public (set-voting-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (>= new-period u144) ERR_INVALID_PROPOSAL) ;; Min 1 day
        (asserts! (<= new-period u4032) ERR_INVALID_PROPOSAL) ;; Max 4 weeks
        (var-set voting-period new-period)
        (ok true)
    )
)

(define-public (set-proposal-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-threshold u0) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-threshold u1000000000000) ERR_INVALID_PROPOSAL) ;; Max reasonable threshold
        (var-set proposal-threshold new-threshold)
        (ok true)
    )
)