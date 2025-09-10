# Nebulith - Decentralized Voting in the Cosmic DAO

A permissionless DAO framework built on Stacks blockchain that enables decentralized governance through token-weighted voting with enhanced security via multi-signature proposal execution. Users can propose, debate, and vote on changes to community rules, funds, or missions.

## Features

### Core Governance
- **Token-weighted voting** with SIP-010 token support
- **Proposal lifecycle management** with multiple states (Pending, Active, Succeeded, Defeated, Executed, Vetoed, Awaiting Signatures)
- **Configurable governance parameters** (quorum thresholds, voting delays, proposal thresholds)
- **Voting delegation system** allowing token holders to delegate voting power
- **Comprehensive security checks** to prevent governance attacks
- **Multi-signature execution** for high-value proposals requiring guardian approval

### Proposal System
- Create proposals with title and description
- Automatic state transitions based on voting outcomes
- Quorum requirements for proposal validity
- Voting delay mechanism to prevent flash loan attacks
- Three voting options: For, Against, Abstain
- **High-value proposal detection** automatically triggers multi-signature requirements
- **Guardian signature collection** for enhanced security on critical proposals

### Security Features
- Input validation for all parameters
- Protection against double voting
- Minimum token requirements for proposal creation
- Veto mechanism for emergency governance intervention
- **Multi-signature guardian system** for high-value proposals
- **Configurable signature thresholds** for different security levels
- **Guardian management** with proper access controls
- Proper error handling throughout the contract

### Multi-Signature System
- **Guardian Management**: Designated guardians can sign high-value proposals
- **Automatic Detection**: Proposals exceeding the high-value threshold require multiple signatures
- **Signature Collection**: Guardians must individually sign proposals before execution
- **Configurable Requirements**: Adjustable number of required signatures
- **State Management**: Proposals await signatures before becoming executable

## Technical Specifications

### Contract Structure
- **Smart Contract Language**: Clarity
- **Blockchain**: Stacks (Bitcoin Layer 2)
- **Token Standard**: SIP-010 compatible
- **Security Model**: Non-Turing complete, decidable smart contracts

### Governance Parameters
- **Quorum Threshold**: 1,000,000 tokens (configurable)
- **Voting Delay**: 144 blocks (~1 day, configurable)
- **Voting Period**: 1,008 blocks (~1 week, configurable)
- **Proposal Threshold**: 100,000 tokens (configurable)
- **High-Value Threshold**: 10,000,000 tokens (configurable)
- **Required Signatures**: 2 guardians (configurable)

### Data Structures
- `proposals`: Stores proposal metadata, voting results, and multi-signature requirements
- `votes`: Records individual voting decisions
- `voter-power`: Manages token holder voting power and delegations
- `delegation-power`: Tracks total delegated voting power
- `guardians`: Manages guardian registry and status
- `proposal-signatures`: Records guardian signatures for proposals
- `proposal-signature-count`: Tracks signature counts for multi-signature proposals

## Usage

### Creating Proposals
```clarity
(contract-call? .nebulith create-proposal 
    "Proposal Title" 
    "Detailed description of the proposal")
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
;; Sign a high-value proposal (guardians only)
(contract-call? .nebulith sign-proposal proposal-id)

;; Add a new guardian (owner only)
(contract-call? .nebulith add-guardian guardian-principal)

;; Remove a guardian (owner only)
(contract-call? .nebulith remove-guardian guardian-principal)
```

### Executing Proposals
```clarity
;; Execute a proposal (automatically handles multi-signature verification)
(contract-call? .nebulith execute-proposal proposal-id)
```

## Installation & Deployment

### Prerequisites
- Clarinet CLI tool
- Stacks wallet for testnet/mainnet deployment
- Node.js (for frontend development)

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
The contract passes `clarinet check` without warnings and includes comprehensive error handling to prevent common vulnerabilities.

## Multi-Signature Workflow

### High-Value Proposal Process
1. **Proposal Creation**: User creates proposal (automatically flagged if high-value)
2. **Voting Period**: Community votes on the proposal
3. **Success Check**: If proposal succeeds and requires multi-signature, state becomes "Awaiting Signatures"
4. **Guardian Signing**: Required number of guardians must sign the proposal
5. **Execution**: Once sufficient signatures are collected, proposal can be executed

### Guardian Management
- **Adding Guardians**: Only the contract owner can add new guardians
- **Removing Guardians**: Owner can remove guardians (must maintain minimum count)
- **Signature Requirements**: Configurable number of signatures required
- **Guardian Registry**: Track active guardians and their addition dates

### Security Considerations
- Guardians cannot sign the same proposal twice
- Minimum guardian count must be maintained
- High-value threshold is configurable
- Signature requirements can be adjusted based on governance needs

## Security Considerations

- All inputs are validated to prevent malicious proposals
- Voting power is verified before allowing votes
- Double voting protection is implemented
- Delegation system prevents voting power manipulation
- Emergency veto mechanism for critical situations
- **Multi-signature protection** for high-value proposals
- **Guardian access controls** prevent unauthorized signatures
- **Minimum guardian requirements** ensure system resilience
- **Configurable thresholds** allow adaptation to changing needs

## API Reference

### New Multi-Signature Functions

#### Guardian Management
- `add-guardian(guardian: principal)` - Add a new guardian
- `remove-guardian(guardian: principal)` - Remove an existing guardian
- `is-guardian(guardian: principal)` - Check if address is a guardian

#### Proposal Signing
- `sign-proposal(proposal-id: uint)` - Sign a proposal as a guardian
- `has-signed(proposal-id: uint, guardian: principal)` - Check if guardian has signed
- `get-signature-count(proposal-id: uint)` - Get current signature count

#### Configuration
- `set-high-value-threshold(threshold: uint)` - Set high-value proposal threshold
- `set-required-signatures(count: uint)` - Set required signature count

### Enhanced Read-Only Functions
- `requires-multisig(proposal-id: uint)` - Check if proposal requires multi-signature
- `is-high-value-proposal(for-votes: uint)` - Check if vote count triggers multi-signature

## Error Codes

### New Multi-Signature Error Codes
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

## Recent Updates

### v2.0 - Multi-Signature Proposal Execution
- Added guardian management system
- Implemented multi-signature requirements for high-value proposals
- Enhanced proposal state management with "Awaiting Signatures" state
- Added configurable high-value thresholds and signature requirements
- Improved security with guardian-based proposal approval
- Enhanced API with guardian and signature management functions

*Nebulith: Empowering decentralized communities through secure, transparent governance with enhanced multi-signature protection.*