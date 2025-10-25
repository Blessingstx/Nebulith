;; Nebulith - Decentralized Voting in the Cosmic DAO
;; A permissionless DAO framework enabling decentralized governance via token-weighted voting
;; with multi-signature proposal execution and integrated treasury management

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
(define-constant ERR_NOT_GUARDIAN (err u110))
(define-constant ERR_ALREADY_SIGNED (err u111))
(define-constant ERR_INSUFFICIENT_SIGNATURES (err u112))
(define-constant ERR_GUARDIAN_EXISTS (err u113))
(define-constant ERR_GUARDIAN_NOT_FOUND (err u114))
(define-constant ERR_MIN_GUARDIANS_REQUIRED (err u115))
(define-constant ERR_INVALID_TREASURY_CONTRACT (err u116))
(define-constant ERR_TREASURY_EXECUTION_FAILED (err u117))
(define-constant ERR_INVALID_AMOUNT (err u118))
(define-constant ERR_INVALID_RECIPIENT (err u119))
(define-constant ERR_TREASURY_NOT_SET (err u120))
(define-constant ERR_PROPOSAL_ALREADY_EXECUTED (err u121))
(define-constant ERR_CANNOT_CANCEL (err u122))

;; Data Variables
(define-data-var next-proposal-id uint u1)
(define-data-var quorum-threshold uint u1000000) ;; 1M tokens required for quorum
(define-data-var voting-delay uint u144) ;; ~1 day in blocks
(define-data-var voting-period uint u1008) ;; ~1 week in blocks
(define-data-var proposal-threshold uint u100000) ;; 100k tokens to create proposal
(define-data-var high-value-threshold uint u10000000) ;; 10M tokens - requires multisig
(define-data-var required-signatures uint u2) ;; Minimum signatures required
(define-data-var guardian-count uint u0) ;; Current number of guardians
(define-data-var treasury-contract (optional principal) none) ;; Treasury contract address

;; Proposal States
(define-constant PROPOSAL_PENDING u0)
(define-constant PROPOSAL_ACTIVE u1)
(define-constant PROPOSAL_SUCCEEDED u2)
(define-constant PROPOSAL_DEFEATED u3)
(define-constant PROPOSAL_EXECUTED u4)
(define-constant PROPOSAL_VETOED u5)
(define-constant PROPOSAL_AWAITING_SIGNATURES u6)
(define-constant PROPOSAL_CANCELLED u7)

;; Proposal Types
(define-constant PROPOSAL_TYPE_GENERAL u0)
(define-constant PROPOSAL_TYPE_TREASURY u1)
(define-constant PROPOSAL_TYPE_PARAMETER u2)

;; Treasury contract trait for fund transfers
(define-trait treasury-trait
    (
        (transfer-funds (uint principal (optional (buff 34))) (response bool uint))
        (get-balance () (response uint uint))
        (is-authorized-dao (principal) (response bool uint))
    )
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
        executed: bool,
        requires-multisig: bool,
        proposal-type: uint,
        treasury-amount: (optional uint),
        treasury-recipient: (optional principal),
        cancelled-at: (optional uint)
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

;; Multi-signature related maps
(define-map guardians
    { guardian: principal }
    { active: bool, added-at: uint }
)

(define-map proposal-signatures
    { proposal-id: uint, guardian: principal }
    { signed: bool, signed-at: uint }
)

(define-map proposal-signature-count
    { proposal-id: uint }
    { count: uint }
)

;; Treasury execution tracking
(define-map treasury-executions
    { proposal-id: uint }
    { executed: bool, execution-block: uint, amount: uint, recipient: principal }
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

(define-read-only (is-guardian (guardian principal))
    (match (map-get? guardians { guardian: guardian })
        guardian-data (get active guardian-data)
        false
    )
)

(define-read-only (has-signed (proposal-id uint) (guardian principal))
    (match (map-get? proposal-signatures { proposal-id: proposal-id, guardian: guardian })
        signature-data (get signed signature-data)
        false
    )
)

(define-read-only (get-signature-count (proposal-id uint))
    (default-to u0
        (get count (map-get? proposal-signature-count { proposal-id: proposal-id })))
)

(define-read-only (requires-multisig (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (get requires-multisig proposal)
        false
    )
)

(define-read-only (is-high-value-proposal (for-votes uint))
    (>= for-votes (var-get high-value-threshold))
)

(define-read-only (get-treasury-contract)
    (var-get treasury-contract)
)

(define-read-only (is-treasury-proposal (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (is-eq (get proposal-type proposal) PROPOSAL_TYPE_TREASURY)
        false
    )
)

(define-read-only (get-treasury-execution (proposal-id uint))
    (map-get? treasury-executions { proposal-id: proposal-id })
)

(define-read-only (is-proposal-cancelled (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (is-eq (get state proposal) PROPOSAL_CANCELLED)
        false
    )
)

(define-read-only (can-cancel-proposal (proposal-id uint) (caller principal))
    (match (get-proposal proposal-id)
        proposal (and 
            (is-eq (get proposer proposal) caller)
            (or (is-eq (get state proposal) PROPOSAL_PENDING)
                (is-eq (get state proposal) PROPOSAL_ACTIVE))
            (not (get executed proposal))
            (is-none (get cancelled-at proposal)))
        false
    )
)

;; Private functions
(define-private (get-effective-voting-power (voter principal))
    (let ((voter-data (get-voter-power voter)))
        (match (get delegated-to voter-data)
            delegate u0
            (get-voting-power voter)
        )
    )
)

(define-private (update-proposal-state (proposal-id uint))
    (let ((current-block stacks-block-height))
        (match (get-proposal proposal-id)
            proposal-data
            (if (< current-block (get start-block proposal-data))
                (ok PROPOSAL_PENDING)
                (if (< current-block (get end-block proposal-data))
                    (ok PROPOSAL_ACTIVE)
                    (if (proposal-succeeded proposal-id)
                        (let ((new-state (if (get requires-multisig proposal-data)
                                            PROPOSAL_AWAITING_SIGNATURES
                                            PROPOSAL_SUCCEEDED)))
                            (map-set proposals { proposal-id: proposal-id }
                                (merge proposal-data { state: new-state }))
                            (ok new-state))
                        (begin
                            (map-set proposals { proposal-id: proposal-id }
                                (merge proposal-data { state: PROPOSAL_DEFEATED }))
                            (ok PROPOSAL_DEFEATED)))))
            (err ERR_PROPOSAL_NOT_FOUND)))
)

(define-private (increment-signature-count (proposal-id uint))
    (let ((current-count (get-signature-count proposal-id)))
        (map-set proposal-signature-count { proposal-id: proposal-id }
            { count: (+ current-count u1) })
        (+ current-count u1))
)

(define-private (validate-proposal-inputs (title (string-ascii 100)) (description (string-ascii 500)))
    (and (> (len title) u0) 
         (<= (len title) u100)
         (> (len description) u0)
         (<= (len description) u500))
)

(define-private (validate-treasury-params (amount uint) (recipient principal))
    (and (> amount u0)
         (<= amount u1000000000000)
         (not (is-eq recipient (as-contract tx-sender)))
         (not (is-eq recipient CONTRACT_OWNER)))
)

(define-private (prepare-treasury-execution (proposal-id uint) (amount uint) (recipient principal))
    (begin
        (map-set treasury-executions { proposal-id: proposal-id }
            { executed: false, execution-block: stacks-block-height, amount: amount, recipient: recipient })
        (ok true))
)

;; Public functions
(define-public (create-proposal 
    (title (string-ascii 100))
    (description (string-ascii 500)))
    (let ((proposal-id (var-get next-proposal-id))
          (start-block (+ stacks-block-height (var-get voting-delay)))
          (end-block (+ start-block (var-get voting-period)))
          (proposer-power (get-effective-voting-power tx-sender))
          (requires-multisig (is-high-value-proposal proposer-power)))
        
        (asserts! (>= proposer-power (var-get proposal-threshold)) ERR_INSUFFICIENT_TOKENS)
        (asserts! (validate-proposal-inputs title description) ERR_INVALID_PROPOSAL)
        
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
                executed: false,
                requires-multisig: requires-multisig,
                proposal-type: PROPOSAL_TYPE_GENERAL,
                treasury-amount: none,
                treasury-recipient: none,
                cancelled-at: none
            })
        
        (if requires-multisig
            (map-set proposal-signature-count { proposal-id: proposal-id } { count: u0 })
            true)
        
        (var-set next-proposal-id (+ proposal-id u1))
        
        (ok proposal-id)
    )
)

(define-public (create-treasury-proposal 
    (title (string-ascii 100))
    (description (string-ascii 500))
    (amount uint)
    (recipient principal))
    (let ((proposal-id (var-get next-proposal-id))
          (start-block (+ stacks-block-height (var-get voting-delay)))
          (end-block (+ start-block (var-get voting-period)))
          (proposer-power (get-effective-voting-power tx-sender))
          (requires-multisig (or (is-high-value-proposal proposer-power) (>= amount (var-get high-value-threshold)))))
        
        (asserts! (is-some (var-get treasury-contract)) ERR_TREASURY_NOT_SET)
        (asserts! (>= proposer-power (var-get proposal-threshold)) ERR_INSUFFICIENT_TOKENS)
        (asserts! (validate-proposal-inputs title description) ERR_INVALID_PROPOSAL)
        (asserts! (validate-treasury-params amount recipient) ERR_INVALID_AMOUNT)
        
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
                executed: false,
                requires-multisig: requires-multisig,
                proposal-type: PROPOSAL_TYPE_TREASURY,
                treasury-amount: (some amount),
                treasury-recipient: (some recipient),
                cancelled-at: none
            })
        
        (if requires-multisig
            (map-set proposal-signature-count { proposal-id: proposal-id } { count: u0 })
            true)
        
        (var-set next-proposal-id (+ proposal-id u1))
        
        (ok proposal-id)
    )
)

(define-public (cancel-proposal (proposal-id uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        (asserts! (is-eq (get proposer proposal-data) tx-sender) ERR_UNAUTHORIZED)
        (asserts! (can-cancel-proposal proposal-id tx-sender) ERR_CANNOT_CANCEL)
        
        (map-set proposals { proposal-id: proposal-id }
            (merge proposal-data { 
                state: PROPOSAL_CANCELLED,
                cancelled-at: (some stacks-block-height)
            }))
        
        (ok true)
    )
)

(define-public (cast-vote (proposal-id uint) (support uint) (voting-power uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (available-power (get-effective-voting-power tx-sender))
          (current-block stacks-block-height))
        
        (asserts! (>= current-block (get start-block proposal-data)) ERR_VOTING_PERIOD_NOT_STARTED)
        (asserts! (< current-block (get end-block proposal-data)) ERR_VOTING_PERIOD_ENDED)
        (asserts! (not (has-voted proposal-id tx-sender)) ERR_ALREADY_VOTED)
        (asserts! (>= available-power voting-power) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> voting-power u0) ERR_INSUFFICIENT_TOKENS)
        (asserts! (<= support u2) ERR_INVALID_PROPOSAL)
        
        (map-set votes { proposal-id: proposal-id, voter: tx-sender }
            { support: support, weight: voting-power, voted-at: current-block })
        
        (let ((updated-proposal
                (if (is-eq support u0)
                    (merge proposal-data { against-votes: (+ (get against-votes proposal-data) voting-power) })
                    (if (is-eq support u1)
                        (let ((new-for-votes (+ (get for-votes proposal-data) voting-power))
                              (check-high-value (or (get requires-multisig proposal-data)
                                                   (is-high-value-proposal new-for-votes)
                                                   (and (is-treasury-proposal proposal-id)
                                                        (match (get treasury-amount proposal-data)
                                                            amount (>= amount (var-get high-value-threshold))
                                                            false)))))
                            (merge proposal-data 
                                { for-votes: new-for-votes,
                                  requires-multisig: check-high-value }))
                        (merge proposal-data { abstain-votes: (+ (get abstain-votes proposal-data) voting-power) })))))
            (map-set proposals { proposal-id: proposal-id } updated-proposal))
        
        (ok true)
    )
)

(define-public (sign-proposal (proposal-id uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (current-state (unwrap! (update-proposal-state proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        (asserts! (is-guardian tx-sender) ERR_NOT_GUARDIAN)
        (asserts! (is-eq current-state PROPOSAL_AWAITING_SIGNATURES) ERR_PROPOSAL_NOT_ACTIVE)
        (asserts! (not (has-signed proposal-id tx-sender)) ERR_ALREADY_SIGNED)
        
        (map-set proposal-signatures { proposal-id: proposal-id, guardian: tx-sender }
            { signed: true, signed-at: stacks-block-height })
        
        (let ((new-count (increment-signature-count proposal-id)))
            (if (>= new-count (var-get required-signatures))
                (map-set proposals { proposal-id: proposal-id }
                    (merge proposal-data { state: PROPOSAL_SUCCEEDED }))
                true))
        
        (ok true)
    )
)

(define-public (delegate-votes (delegate-to principal) (power uint))
    (let ((current-power (get power (get-voter-power tx-sender)))
          (current-delegation (get total-delegated (get-delegation-power delegate-to))))
        
        (asserts! (>= current-power power) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> power u0) ERR_INSUFFICIENT_TOKENS)
        (asserts! (not (is-eq tx-sender delegate-to)) ERR_UNAUTHORIZED)
        
        (map-set voter-power { voter: tx-sender }
            { power: (- current-power power), delegated-to: (some delegate-to) })
        
        (map-set delegation-power { delegate: delegate-to }
            { total-delegated: (+ current-delegation power) })
        
        (ok true)
    )
)

(define-public (revoke-delegation (delegate-from principal) (power uint))
    (let ((voter-data (get-voter-power tx-sender))
          (current-delegation (get total-delegated (get-delegation-power delegate-from))))
        
        (asserts! (is-eq (get delegated-to voter-data) (some delegate-from)) ERR_UNAUTHORIZED)
        (asserts! (>= current-delegation power) ERR_INSUFFICIENT_TOKENS)
        (asserts! (> power u0) ERR_INSUFFICIENT_TOKENS)
        
        (map-set voter-power { voter: tx-sender }
            { power: (+ (get power voter-data) power), delegated-to: none })
        
        (map-set delegation-power { delegate: delegate-from }
            { total-delegated: (- current-delegation power) })
        
        (ok true)
    )
)

(define-public (set-initial-voting-power (voter principal) (power uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq voter CONTRACT_OWNER)) ERR_UNAUTHORIZED)
        (asserts! (> power u0) ERR_INSUFFICIENT_TOKENS)
        (asserts! (<= power u1000000000000) ERR_INSUFFICIENT_TOKENS)
        
        (map-set voter-power { voter: voter }
            { power: power, delegated-to: none })
        
        (ok true)
    )
)

(define-public (execute-proposal (proposal-id uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (current-state (unwrap! (update-proposal-state proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        (asserts! (is-eq current-state PROPOSAL_SUCCEEDED) ERR_PROPOSAL_NOT_ACTIVE)
        (asserts! (not (get executed proposal-data)) ERR_PROPOSAL_ALREADY_EXECUTED)
        (asserts! (not (is-eq (get proposal-type proposal-data) PROPOSAL_TYPE_TREASURY)) ERR_TREASURY_NOT_SET)
        
        (if (get requires-multisig proposal-data)
            (asserts! (>= (get-signature-count proposal-id) (var-get required-signatures)) 
                     ERR_INSUFFICIENT_SIGNATURES)
            true)
        
        (map-set proposals { proposal-id: proposal-id }
            (merge proposal-data { executed: true, state: PROPOSAL_EXECUTED }))
        
        (ok true)
    )
)

(define-public (execute-proposal-with-treasury (proposal-id uint) (treasury <treasury-trait>))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND))
          (current-state (unwrap! (update-proposal-state proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        (asserts! (is-eq current-state PROPOSAL_SUCCEEDED) ERR_PROPOSAL_NOT_ACTIVE)
        (asserts! (not (get executed proposal-data)) ERR_PROPOSAL_ALREADY_EXECUTED)
        (asserts! (is-eq (get proposal-type proposal-data) PROPOSAL_TYPE_TREASURY) ERR_INVALID_PROPOSAL)
        
        (if (get requires-multisig proposal-data)
            (asserts! (>= (get-signature-count proposal-id) (var-get required-signatures)) 
                     ERR_INSUFFICIENT_SIGNATURES)
            true)
        
        (let ((amount (unwrap! (get treasury-amount proposal-data) ERR_INVALID_AMOUNT))
              (recipient (unwrap! (get treasury-recipient proposal-data) ERR_INVALID_RECIPIENT)))
            (unwrap! (contract-call? treasury transfer-funds amount recipient none) ERR_TREASURY_EXECUTION_FAILED)
            (map-set treasury-executions { proposal-id: proposal-id }
                { executed: true, execution-block: stacks-block-height, amount: amount, recipient: recipient }))
        
        (map-set proposals { proposal-id: proposal-id }
            (merge proposal-data { executed: true, state: PROPOSAL_EXECUTED }))
        
        (ok true)
    )
)

(define-public (veto-proposal (proposal-id uint))
    (let ((proposal-data (unwrap! (get-proposal proposal-id) ERR_PROPOSAL_NOT_FOUND)))
        
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> proposal-id u0) ERR_INVALID_PROPOSAL)
        (asserts! (< proposal-id (var-get next-proposal-id)) ERR_PROPOSAL_NOT_FOUND)
        (asserts! (not (is-eq (get state proposal-data) PROPOSAL_EXECUTED)) ERR_PROPOSAL_NOT_ACTIVE)
        (asserts! (not (is-eq (get state proposal-data) PROPOSAL_VETOED)) ERR_PROPOSAL_NOT_ACTIVE)
        
        (map-set proposals { proposal-id: proposal-id }
            (merge proposal-data { state: PROPOSAL_VETOED }))
        
        (ok true)
    )
)

;; Guardian management functions
(define-public (add-guardian (new-guardian principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-guardian new-guardian)) ERR_GUARDIAN_EXISTS)
        
        (map-set guardians { guardian: new-guardian }
            { active: true, added-at: stacks-block-height })
        
        (var-set guardian-count (+ (var-get guardian-count) u1))
        
        (ok true)
    )
)

(define-public (remove-guardian (guardian principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (is-guardian guardian) ERR_GUARDIAN_NOT_FOUND)
        (asserts! (> (var-get guardian-count) (var-get required-signatures)) ERR_MIN_GUARDIANS_REQUIRED)
        
        (map-delete guardians { guardian: guardian })
        
        (var-set guardian-count (- (var-get guardian-count) u1))
        
        (ok true)
    )
)

;; Treasury management functions
(define-public (set-treasury-contract (treasury principal))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq treasury (as-contract tx-sender))) ERR_INVALID_TREASURY_CONTRACT)
        
        (var-set treasury-contract (some treasury))
        
        (ok true)
    )
)

(define-public (remove-treasury-contract)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        
        (var-set treasury-contract none)
        
        (ok true)
    )
)

;; Admin functions
(define-public (set-quorum-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-threshold u0) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-threshold u1000000000000) ERR_INVALID_PROPOSAL)
        (var-set quorum-threshold new-threshold)
        (ok true)
    )
)

(define-public (set-voting-delay (new-delay uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (>= new-delay u1) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-delay u2016) ERR_INVALID_PROPOSAL)
        (var-set voting-delay new-delay)
        (ok true)
    )
)

(define-public (set-voting-period (new-period uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (>= new-period u144) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-period u4032) ERR_INVALID_PROPOSAL)
        (var-set voting-period new-period)
        (ok true)
    )
)

(define-public (set-proposal-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-threshold u0) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-threshold u1000000000000) ERR_INVALID_PROPOSAL)
        (var-set proposal-threshold new-threshold)
        (ok true)
    )
)

(define-public (set-high-value-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-threshold u0) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-threshold u1000000000000) ERR_INVALID_PROPOSAL)
        (var-set high-value-threshold new-threshold)
        (ok true)
    )
)

(define-public (set-required-signatures (new-requirement uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
        (asserts! (> new-requirement u0) ERR_INVALID_PROPOSAL)
        (asserts! (<= new-requirement (var-get guardian-count)) ERR_INVALID_PROPOSAL)
        (var-set required-signatures new-requirement)
        (ok true)
    )
)