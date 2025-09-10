# Nebulith - Decentralized Voting in the Cosmic DAO

A permissionless DAO framework built on Stacks blockchain that enables decentralized governance through token-weighted voting with enhanced security via multi-signature proposal execution and integrated treasury management. Users can propose, debate, and vote on changes to community rules, funds, or missions with direct automated fund allocation capabilities.

## Features

### Core Governance
- **Token-weighted voting** with SIP-010 token support
- **Proposal lifecycle management** with multiple states (Pending, Active, Succeeded, Defeated, Executed, Vetoed, Awaiting Signatures)
- **Configurable governance parameters** (quorum thresholds, voting delays, proposal thresholds)
- **Voting delegation system** allowing token holders to delegate voting power
- **Comprehensive security checks** to prevent governance attacks
- **Multi-signature execution** for high-value proposals requiring guardian approval
- **Integrated treasury management** with automated fund allocation based on proposal outcomes

### Proposal System
- **General Proposals**: Create proposals for governance decisions with title and description
- **Treasury Proposals**: Create proposals for fund allocation with specified amounts and recipients
- **Parameter Proposals**: Modify governance parameters through community voting
- Automatic state transitions based on voting outcomes
- Quorum requirements for proposal validity
- Voting delay mechanism to prevent flash loan attacks
- Three voting options: For, Against, Abstain
- **High-value proposal detection** automatically triggers multi-signature requirements
- **Guardian signature collection** for enhanced security on critical proposals

### Treasury Management Integration
- **Direct Treasury Contract Integration**: Connect to multi-signature treasury contracts for automated fund transfers
- **Treasury Proposal Creation**: Specialized proposals for fund allocation with built-in validation
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
- **Multi-signature guardian system** for high-value and treasury proposals
- **Configurable signature thresholds** for different security levels
- **Guardian management** with proper access controls and minimum requirements
- **Treasury contract validation** to ensure secure fund management
- Proper error handling throughout the contract with specific treasury-related error codes

### Multi-Signature System
- **Guardian Management**: Designated guardians can sign high-value and treasury proposals
- **Automatic Detection**: Proposals exceeding thresholds require multiple signatures
- **Signature Collection**: Guardians must individually sign proposals before execution
- **Configurable Requirements**: Adjustable number of required signatures
- **State Management**: Proposals await signatures before becoming executable
- **Treasury Integration**: Treasury proposals automatically integrate with multi-sig requirements

## Technical Specifications

### Contract Structure
- **Smart Contract Language**: Clarity
- **Blockchain**: Stacks (Bitcoin Layer 2)
- **Token Standard**: SIP-010 compatible
- **Security Model**: Non-Turing complete, decidable smart contracts
- **Treasury Integration**: Compatible with multi-signature treasury contracts

### Governance Parameters
- **Quorum Threshold**: 1,000,000 tokens (configurable)
- **Voting Delay**: 144 blocks (~1 day, configurable)
- **Voting Period**: 1,008 blocks (~1 week, configurable)
- **Proposal Threshold**: 100,000 tokens (configurable)
- **High-Value Threshold**: 10,000,000 tokens (configurable)
- **Required Signatures**: 2 guardians (configurable)

### Data Structures
- `proposals`: Enhanced with treasury proposal support, amounts, and recipients
- `votes`: Records individual voting decisions
- `voter-power`: Manages token holder voting power and delegations
- `delegation-power`: Tracks total delegated voting power
- `guardians`: Manages guardian registry and status
- `proposal-signatures`: Records guardian signatures for proposals
- `proposal-signature-count`: Tracks signature counts for multi-signature proposals
- `treasury-executions`: **NEW** - Tracks treasury fund transfers and execution details

### Treasury Contract Integration
- **Treasury Trait**: Defines interface for compatible treasury contracts
- **Fund Transfer**: Automated execution of approved treasury proposals
- **Balance Queries**: Check treasury balance and authorization
- **Execution Tracking**: Detailed logs of all treasury operations

## Usage

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

### Executing Proposals
```clarity
;; Execute any proposal (automatically handles treasury transfers)
(contract-call? .nebulith execute-proposal proposal-id)
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
The contract passes `clarinet check` without warnings and includes comprehensive error handling to prevent common vulnerabilities, including treasury-specific validations.

## Treasury Management Workflow

### Treasury Proposal Process
1. **Treasury Setup**: Owner configures treasury contract address
2. **Proposal Creation**: User creates treasury proposal with amount and recipient
3. **Validation**: System validates amount, recipient, and treasury contract
4. **Voting Period**: Community votes on fund allocation
5. **Multi-Signature**: High-value treasury proposals require guardian signatures
6. **Execution**: Successful proposals automatically trigger treasury fund transfer
7. **Tracking**: Execution details are logged for transparency

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

## Multi-Signature Workflow

### High-Value and Treasury Proposal Process
1. **Proposal Creation**: User creates proposal (automatically flagged if high-value or treasury)
2. **Voting Period**: Community votes on the proposal
3. **Success Check**: If proposal succeeds and requires multi-signature, state becomes "Awaiting Signatures"
4. **Guardian Signing**: Required number of guardians must sign the proposal
5. **Execution**: Once sufficient signatures are collected, proposal executes (including treasury transfers)

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
- **Multi-signature protection** for high-value and treasury proposals
- **Guardian access controls** prevent unauthorized signatures
- **Minimum guardian requirements** ensure system resilience
- **Treasury contract validation** ensures secure fund management
- **Configurable thresholds** allow adaptation to changing needs

## API Reference

### New Treasury Management Functions

#### Treasury Proposal Creation
- `create-treasury-proposal(title, description, amount, recipient)` - Create treasury funding proposal
- `is-treasury-proposal(proposal-id)` - Check if proposal is treasury type
- `get-treasury-execution(proposal-id)` - Get treasury execution details

#### Treasury Configuration
- `set-treasury-contract(treasury)` - Set treasury contract address
- `remove-treasury-contract()` - Remove treasury contract
- `get-treasury-contract()` - Get current treasury contract

#### Enhanced Proposal Functions
- `execute-proposal(proposal-id)` - Execute proposal (handles treasury transfers automatically)

### Enhanced Read-Only Functions
- `requires-multisig(proposal-id)` - Check if proposal requires multi-signature
- `is-high-value-proposal(for-votes)` - Check if vote count triggers multi-signature
- `get-treasury-contract()` - Get configured treasury contract address

### Multi-Signature Functions (Existing)
- `add-guardian(guardian)` - Add new guardian
- `remove-guardian(guardian)` - Remove existing guardian
- `sign-proposal(proposal-id)` - Sign proposal as guardian
- `has-signed(proposal-id, guardian)` - Check guardian signature status
- `get-signature-count(proposal-id)` - Get current signature count

## Error Codes

### New Treasury Error Codes
- `ERR_INVALID_TREASURY_CONTRACT (u116)` - Invalid treasury contract address
- `ERR_TREASURY_EXECUTION_FAILED (u117)` - Treasury fund transfer failed
- `ERR_INVALID_AMOUNT (u118)` - Invalid treasury amount specified
- `ERR_INVALID_RECIPIENT (u119)` - Invalid recipient for treasury transfer
- `ERR_TREASURY_NOT_SET (u120)` - Treasury contract not configured

### Multi-Signature Error Codes (Existing)
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
- **Treasury integration improvements**
- **New treasury contract implementations**

## Recent Updates

### v3.0 - Treasury Management Integration
- **Direct Treasury Contract Integration**: Seamless connection with multi-signature treasury contracts
- **Treasury Proposal System**: Specialized proposals for fund allocation with comprehensive validation
- **Automated Fund Execution**: Successful treasury proposals automatically trigger secure fund transfers
- **Enhanced Multi-Signature Support**: Treasury proposals integrate with existing guardian approval system
- **Execution Tracking**: Detailed logging and monitoring of all treasury operations
- **Flexible Configuration**: Dynamic treasury contract setup and management
- **Security Enhancements**: Additional validation layers for treasury operations and fund protection
- **Comprehensive API**: Extended API for treasury management and monitoring

### v2.0 - Multi-Signature Proposal Execution (Previous)
- Added guardian management system
- Implemented multi-signature requirements for high-value proposals
- Enhanced proposal state management with "Awaiting Signatures" state
- Added configurable high-value thresholds and signature requirements
- Improved security with guardian-based proposal approval
- Enhanced API with guardian and signature management functions

*Nebulith: Empowering decentralized communities through secure, transparent governance with enhanced multi-signature protection and integrated treasury management.*