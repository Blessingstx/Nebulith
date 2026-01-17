# Nebulith - Decentralized Voting in the Cosmic DAO

A permissionless DAO framework built on Stacks blockchain that enables decentralized governance through token-weighted voting with enhanced security via multi-signature proposal execution, integrated treasury management, and intelligent proposal queue system.

## Features

### Core Governance
- **Token-weighted voting** with SIP-010 token support
- **Proposal lifecycle management** with multiple states (Pending, Active, Succeeded, Defeated, Executed, Vetoed, Awaiting Signatures, Cancelled)
- **Proposal cancellation** allowing proposers to cancel their own proposals before execution
- **Proposal queue system** preventing spam and manipulation with configurable limits
- **Duplicate detection** using content hashing to prevent identical proposals
- **Configurable governance parameters** (quorum thresholds, voting delays, proposal thresholds)
- **Voting delegation system** allowing token holders to delegate voting power
- **Comprehensive security checks** to prevent governance attacks
- **Multi-signature execution** for high-value proposals requiring guardian approval
- **Integrated treasury management** with automated fund allocation based on proposal outcomes

### Proposal System
- **General Proposals**: Create proposals for governance decisions with title and description
- **Treasury Proposals**: Create proposals for fund allocation with specified amounts and recipients
- **Parameter Proposals**: Modify governance parameters through community voting
- **Proposal Cancellation**: Proposers can cancel their own pending or active proposals
- **Queue Management**: Limits active proposals per user (default: 10) to prevent spam
- **Duplicate Prevention**: Content hash registry prevents submission of identical proposals
- Automatic state transitions based on voting outcomes
- Quorum requirements for proposal validity
- Voting delay mechanism to prevent flash loan attacks
- Three voting options: For, Against, Abstain
- **High-value proposal detection** automatically triggers multi-signature requirements
- **Guardian signature collection** for enhanced security on critical proposals

### Treasury Management Integration
- **Direct Treasury Contract Integration**: Connect to multi-signature treasury contracts for automated fund transfers
- **Treasury Proposal Creation**: Specialized proposals for fund allocation with comprehensive validation
- **Automated Fund Execution**: Successful treasury proposals automatically trigger fund transfers
- **High-Value Protection**: Treasury proposals above threshold require guardian approval
- **Execution Tracking**: Monitor treasury transfers with detailed execution logs
- **Flexible Treasury Setup**: Configure and change treasury contracts through governance
- **Comprehensive Validation**: Validate amounts, recipients, and treasury contract compatibility

### Security Features
- Input validation for all parameters including treasury amounts and recipients
- Protection against double voting and unauthorized access
- Minimum token requirements for proposal creation
- Veto mechanism for emergency governance intervention
- **Proposal queue limits** to prevent spam and ensure quality governance
- **Content hash verification** to prevent duplicate or manipulative proposals
- **Automatic queue management** tracking active proposals per user
- **Proposal cancellation controls** to prevent abuse while allowing flexibility
- **Multi-signature guardian system** for high-value and treasury proposals
- **Configurable signature thresholds** for different security levels
- **Guardian management** with proper access controls and minimum requirements
- **Treasury contract validation** to ensure secure fund management
- Proper error handling throughout the contract with specific error codes

### Multi-Signature System
- **Guardian Management**: Designated guardians can sign high-value and treasury proposals
- **Automatic Detection**: Proposals exceeding thresholds require multiple signatures
- **Signature Collection**: Guardians must individually sign proposals before execution
- **Configurable Requirements**: Adjustable number of required signatures
- **State Management**: Proposals await signatures before becoming executable
- **Treasury Integration**: Treasury proposals automatically integrate with multi-sig requirements

### Proposal Queue System
- **Per-User Limits**: Configurable maximum active proposals per user (default: 10)
- **Global Tracking**: Monitor total active proposals across the DAO
- **Automatic Cleanup**: Queue decrements when proposals are executed, cancelled, or vetoed
- **Spam Prevention**: Prevents proposal flooding and maintains governance quality
- **Content Deduplication**: Hash-based registry prevents identical proposal resubmission
- **Queue Queries**: Check user queue status and remaining capacity before submission

## Technical Specifications

### Contract Structure
- **Smart Contract Language**: Clarity
- **Blockchain**: Stacks (Bitcoin Layer 2)
- **Token Standard**: SIP-010 compatible
- **Security Model**: Non-Turing complete, decidable smart contracts
- **Treasury Integration**: Compatible with multi-signature treasury contracts
- **Queue System**: SHA-256 content hashing for duplicate detection

### Governance Parameters
- **Quorum Threshold**: 1,000,000 tokens (configurable)
- **Voting Delay**: 144 blocks (~1 day, configurable)
- **Voting Period**: 1,008 blocks (~1 week, configurable)
- **Proposal Threshold**: 100,000 tokens (configurable)
- **High-Value Threshold**: 10,000,000 tokens (configurable)
- **Required Signatures**: 2 guardians (configurable)
- **Max Queue Size**: 10 active proposals per user (configurable)

### Data Structures
- `proposals`: Enhanced with treasury proposal support, amounts, recipients, cancellation tracking, and creation timestamps
- `votes`: Records individual voting decisions
- `voter-power`: Manages token holder voting power and delegations
- `delegation-power`: Tracks total delegated voting power
- `guardians`: Manages guardian registry and status
- `proposal-signatures`: Records guardian signatures for proposals
- `proposal-signature-count`: Tracks signature counts for multi-signature proposals
- `treasury-executions`: Tracks treasury fund transfers and execution details
- `proposer-queue`: Tracks active proposal count per user and last proposal block
- `proposal-hash-registry`: Content hash registry preventing duplicate proposals

### Treasury Contract Integration
- **Treasury Trait**: Defines interface for compatible treasury contracts
- **Fund Transfer**: Automated execution of approved treasury proposals
- **Balance Queries**: Check treasury balance and authorization
- **Execution Tracking**: Detailed logs of all treasury operations

## Usage

### Checking Proposal Queue Status
```clarity
;; Check if you can create a proposal
(contract-call? .nebulith can-create-proposal tx-sender)

;; Get your current queue status
(contract-call? .nebulith get-proposer-queue tx-sender)

;; Get total active proposals
(contract-call? .nebulith get-active-proposal-count)
```

### Creating General Proposals
```clarity
(contract-call? .nebulith create-proposal 
    "Proposal Title" 
    "Detailed description of the proposal")
```

### Creating Treasury Proposals
```clarity
(contract-call? .nebulith create-treasury-proposal 
    "Fund Allocation Proposal"
    "Proposal to allocate 1M tokens for development"
    u1000000    ;; Amount in micro-tokens
    'SP1EXAMPLE) ;; Recipient address
```

### Cancelling Proposals
```clarity
;; Proposers can cancel their own pending or active proposals
(contract-call? .nebulith cancel-proposal proposal-id)

;; Check if you can cancel
(contract-call? .nebulith can-cancel-proposal proposal-id tx-sender)
```

### Casting Votes
```clarity
(contract-call? .nebulith cast-vote 
    proposal-id 
    vote-support    ;; 0=against, 1=for, 2=abstain
    voting-power)   ;; Amount of voting power to use
```

### Delegating Votes
```clarity
(contract-call? .nebulith delegate-votes 
    delegate-principal 
    power-amount)
```

### Guardian Operations
```clarity
;; Sign a high-value or treasury proposal (guardians only)
(contract-call? .nebulith sign-proposal proposal-id)

;; Add a new guardian (owner only)
(contract-call? .nebulith add-guardian guardian-principal)

;; Remove a guardian (owner only)
(contract-call? .nebulith remove-guardian guardian-principal)
```

### Treasury Management
```clarity
;; Set treasury contract (owner only)
(contract-call? .nebulith set-treasury-contract treasury-principal)

;; Remove treasury contract (owner only)
(contract-call? .nebulith remove-treasury-contract)

;; Check treasury execution status
(contract-call? .nebulith get-treasury-execution proposal-id)
```

### Queue Management
```clarity
;; Set maximum queue size (owner only)
(contract-call? .nebulith set-max-queue-size u15)

;; Check if proposal hash exists
(contract-call? .nebulith proposal-hash-exists content-hash)
```

### Executing Proposals
```clarity
;; Execute general proposal
(contract-call? .nebulith execute-proposal proposal-id)

;; Execute treasury proposal with treasury trait
(contract-call? .nebulith execute-proposal-with-treasury proposal-id treasury-contract)
```

## Installation & Deployment

### Prerequisites
- Clarinet CLI tool
- Stacks wallet for testnet/mainnet deployment
- Node.js (for frontend development)
- Compatible treasury contract (for treasury functionality)

### Local Development
```bash
# Clone the repository
git clone <repository-url>
cd nebulith

# Check contract syntax
clarinet check

# Run tests
clarinet test

# Deploy to testnet
clarinet deploy --testnet
```

### Contract Verification
The contract passes `clarinet check` without warnings and includes comprehensive error handling to prevent common vulnerabilities, including treasury-specific validations and queue management.

## Proposal Queue Workflow

### Queue Management Process
1. **Queue Check**: System validates user hasn't reached max active proposals
2. **Hash Verification**: Content hash checked against registry to prevent duplicates
3. **Proposal Creation**: Proposal created and queue counter incremented
4. **Hash Registration**: Content hash registered to prevent future duplicates
5. **Queue Tracking**: Active proposal count tracked per user and globally
6. **Automatic Cleanup**: Queue decremented when proposals complete their lifecycle

### Queue Security Benefits
- **Spam Prevention**: Limits prevent malicious actors from flooding governance
- **Resource Management**: Ensures system resources aren't overwhelmed
- **Quality Control**: Encourages thoughtful proposal creation
- **Duplicate Prevention**: Hash-based detection stops identical proposal resubmission
- **Fair Access**: Prevents single users from monopolizing governance bandwidth

## Treasury Management Workflow

### Treasury Proposal Process
1. **Treasury Setup**: Owner configures treasury contract address
2. **Proposal Creation**: User creates treasury proposal with amount and recipient
3. **Queue Validation**: System checks user queue capacity and duplicate detection
4. **Validation**: System validates amount, recipient, and treasury contract
5. **Voting Period**: Community votes on fund allocation
6. **Multi-Signature**: High-value treasury proposals require guardian signatures
7. **Execution**: Successful proposals automatically trigger treasury fund transfer
8. **Queue Cleanup**: Proposal removed from active queue upon execution
9. **Tracking**: Execution details are logged for transparency

### Treasury Contract Requirements
- **SIP-010 Compatible**: Must support standard token operations
- **Multi-Signature Support**: Integrated with guardian approval system
- **Authorization Checks**: Verify DAO authorization for fund transfers
- **Balance Management**: Provide balance queries and transfer capabilities

### Security Considerations for Treasury
- **Amount Validation**: Reasonable limits on fund transfer amounts
- **Recipient Validation**: Prevent transfers to contract or owner addresses
- **Treasury Contract Validation**: Ensure treasury contract compatibility
- **Multi-Signature Requirements**: High-value transfers require guardian approval
- **Execution Tracking**: Comprehensive logging of all treasury operations
- **Emergency Controls**: Veto mechanism for problematic treasury proposals

## Proposal Cancellation Workflow

### Cancellation Process
1. **Authorization Check**: Only the original proposer can cancel their proposal
2. **State Validation**: Only pending or active proposals can be cancelled
3. **Execution Check**: Already executed proposals cannot be cancelled
4. **Queue Decrement**: Active proposal count reduced for proposer
5. **Timestamp Recording**: Cancellation time is recorded on-chain
6. **State Update**: Proposal state is updated to CANCELLED

### Cancellation Rules
- **Proposer Only**: Only the original proposer can cancel their proposal
- **Time Window**: Can cancel during pending or active voting periods
- **No Refunds**: Proposal threshold tokens are not refunded upon cancellation
- **Permanent**: Cancelled proposals cannot be reactivated
- **Audit Trail**: Cancellation timestamp is permanently recorded
- **Queue Impact**: Cancellation frees up queue slot for new proposals

### Use Cases for Cancellation
- **Error Correction**: Proposer made a mistake in proposal details
- **Changed Circumstances**: External conditions have changed
- **Community Feedback**: Negative community response before voting concludes
- **Better Alternative**: A superior proposal has been submitted
- **Testing**: Remove test proposals in development environments
- **Queue Management**: Free up queue space for improved proposals

## Multi-Signature Workflow

### High-Value and Treasury Proposal Process
1. **Proposal Creation**: User creates proposal (automatically flagged if high-value or treasury)
2. **Queue Management**: Proposal added to user's active queue
3. **Voting Period**: Community votes on the proposal
4. **Success Check**: If proposal succeeds and requires multi-signature, state becomes "Awaiting Signatures"
5. **Guardian Signing**: Required number of guardians must sign the proposal
6. **Execution**: Once sufficient signatures are collected, proposal executes (including treasury transfers)
7. **Queue Cleanup**: Proposal removed from active queue after execution

### Guardian Management
- **Adding Guardians**: Only the contract owner can add new guardians
- **Removing Guardians**: Owner can remove guardians (must maintain minimum count)
- **Signature Requirements**: Configurable number of signatures required
- **Guardian Registry**: Track active guardians and their addition dates

### Security Considerations
- All inputs are validated to prevent malicious proposals and treasury operations
- Voting power is verified before allowing votes
- Double voting protection is implemented
- Delegation system prevents voting power manipulation
- Emergency veto mechanism for critical situations
- **Proposal queue limits** prevent spam and ensure governance quality
- **Content hash verification** stops duplicate proposals and manipulation attempts
- **Automatic queue cleanup** maintains accurate state across all operations
- **Proposal cancellation** provides flexibility while preventing abuse
- **Multi-signature protection** for high-value and treasury proposals
- **Guardian access controls** prevent unauthorized signatures
- **Minimum guardian requirements** ensure system resilience
- **Treasury contract validation** ensures secure fund management
- **Configurable thresholds** allow adaptation to changing needs

## API Reference

### Proposal Queue Functions

#### Queue Status
- `can-create-proposal(proposer)` - Check if proposer can create new proposal
- `get-proposer-queue(proposer)` - Get proposer's queue status and last proposal block
- `get-active-proposal-count()` - Get total active proposals across DAO
- `proposal-hash-exists(content-hash)` - Check if proposal with hash already exists

#### Queue Management
- `set-max-queue-size(new-size)` - Set maximum active proposals per user (owner only, max 50)

### Proposal Management Functions

#### Proposal Cancellation
- `cancel-proposal(proposal-id)` - Cancel own pending/active proposal
- `is-proposal-cancelled(proposal-id)` - Check if proposal is cancelled
- `can-cancel-proposal(proposal-id, caller)` - Check if caller can cancel proposal

### Treasury Management Functions

#### Treasury Proposal Creation
- `create-treasury-proposal(title, description, amount, recipient)` - Create treasury funding proposal
- `is-treasury-proposal(proposal-id)` - Check if proposal is treasury type
- `get-treasury-execution(proposal-id)` - Get treasury execution details

#### Treasury Configuration
- `set-treasury-contract(treasury)` - Set treasury contract address
- `remove-treasury-contract()` - Remove treasury contract
- `get-treasury-contract()` - Get current treasury contract

#### Proposal Execution
- `execute-proposal(proposal-id)` - Execute general proposal
- `execute-proposal-with-treasury(proposal-id, treasury)` - Execute treasury proposal with trait

### Enhanced Read-Only Functions
- `requires-multisig(proposal-id)` - Check if proposal requires multi-signature
- `is-high-value-proposal(for-votes)` - Check if vote count triggers multi-signature
- `get-treasury-contract()` - Get configured treasury contract address

### Multi-Signature Functions
- `add-guardian(guardian)` - Add new guardian
- `remove-guardian(guardian)` - Remove existing guardian
- `sign-proposal(proposal-id)` - Sign proposal as guardian
- `has-signed(proposal-id, guardian)` - Check guardian signature status
- `get-signature-count(proposal-id)` - Get current signature count

## Error Codes

### Queue Error Codes
- `ERR_PROPOSAL_QUEUE_FULL (u123)` - User has reached maximum active proposals
- `ERR_DUPLICATE_PROPOSAL (u124)` - Proposal with identical content already exists

### Existing Error Codes
- `ERR_PROPOSAL_ALREADY_EXECUTED (u121)` - Proposal has already been executed
- `ERR_CANNOT_CANCEL (u122)` - Proposal cannot be cancelled in current state

### Treasury Error Codes
- `ERR_INVALID_TREASURY_CONTRACT (u116)` - Invalid treasury contract address
- `ERR_TREASURY_EXECUTION_FAILED (u117)` - Treasury fund transfer failed
- `ERR_INVALID_AMOUNT (u118)` - Invalid treasury amount specified
- `ERR_INVALID_RECIPIENT (u119)` - Invalid recipient for treasury transfer
- `ERR_TREASURY_NOT_SET (u120)` - Treasury contract not configured

### Multi-Signature Error Codes
- `ERR_NOT_GUARDIAN (u110)` - Caller is not a registered guardian
- `ERR_ALREADY_SIGNED (u111)` - Guardian has already signed this proposal
- `ERR_INSUFFICIENT_SIGNATURES (u112)` - Not enough guardian signatures collected
- `ERR_GUARDIAN_EXISTS (u113)` - Guardian already exists in registry
- `ERR_GUARDIAN_NOT_FOUND (u114)` - Guardian not found in registry
- `ERR_MIN_GUARDIANS_REQUIRED (u115)` - Cannot remove guardian, minimum count required

## Contributing

We welcome contributions! Please see our contributing guidelines and submit pull requests for:
- Bug fixes
- Feature enhancements
- Security improvements
- Documentation updates
- Test coverage expansion
- Multi-signature system enhancements
- Guardian management improvements
- Treasury integration improvements
- New treasury contract implementations
- Proposal lifecycle enhancements
- Queue management optimizations
- Anti-spam mechanism improvements

## Recent Updates

### v3.2 - Proposal Queue & Duplicate Prevention
- **Proposal Queue System**: Per-user active proposal limits (default: 10, max: 50)
- **Duplicate Detection**: Content hash registry prevents identical proposals
- **Automatic Queue Management**: Tracking across proposal lifecycle (create, execute, cancel, veto)
- **Global Monitoring**: Total active proposal count tracking
- **Spam Prevention**: Multiple layers of protection against governance manipulation
- **Enhanced Security**: Queue limits combined with hash verification
- **Improved User Experience**: Clear queue status and capacity checking
- **Better Governance Quality**: Encourages thoughtful proposal creation

### v3.1 - Proposal Cancellation & Enhanced Security (Previous)
- Proposal Cancellation: Proposers can now cancel their own pending or active proposals
- Enhanced State Management: Added CANCELLED state to proposal lifecycle
- Cancellation Tracking: On-chain timestamp recording for cancelled proposals
- Improved Error Handling: New error codes for execution and cancellation states
- Security Enhancements: Additional validation to prevent abuse of cancellation feature
- Better User Control: Gives proposers flexibility to correct mistakes or respond to feedback
- Audit Trail: Complete cancellation history with timestamps for transparency

### v3.0 - Treasury Management Integration (Previous)
- Direct Treasury Contract Integration with multi-signature treasury contracts
- Treasury Proposal System for fund allocation with comprehensive validation
- Automated Fund Execution for successful treasury proposals
- Enhanced Multi-Signature Support integrated with guardian approval
- Execution Tracking with detailed logging and monitoring
- Flexible Configuration for dynamic treasury contract setup
- Security Enhancements with additional validation layers
- Comprehensive API extended for treasury management

### v2.0 - Multi-Signature Proposal Execution (Previous)
- Added guardian management system
- Implemented multi-signature requirements for high-value proposals
- Enhanced proposal state management with "Awaiting Signatures" state
- Added configurable high-value thresholds and signature requirements
- Improved security with guardian-based proposal approval
- Enhanced API with guardian and signature management functions

*Nebulith: Empowering decentralized communities through secure, transparent governance with enhanced multi-signature protection, integrated treasury management, intelligent queue management, and flexible proposal lifecycle controls.*