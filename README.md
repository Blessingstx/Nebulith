# Nebulith - Decentralized Voting in the Cosmic DAO

A permissionless DAO framework built on Stacks blockchain that enables decentralized governance through token-weighted voting. Users can propose, debate, and vote on changes to community rules, funds, or missions.

## Features

### Core Governance
- **Token-weighted voting** with SIP-010 token support
- **Proposal lifecycle management** with multiple states (Pending, Active, Succeeded, Defeated, Executed, Vetoed)
- **Configurable governance parameters** (quorum thresholds, voting delays, proposal thresholds)
- **Voting delegation system** allowing token holders to delegate voting power
- **Comprehensive security checks** to prevent governance attacks

### Proposal System
- Create proposals with title and description
- Automatic state transitions based on voting outcomes
- Quorum requirements for proposal validity
- Voting delay mechanism to prevent flash loan attacks
- Three voting options: For, Against, Abstain

### Security Features
- Input validation for all parameters
- Protection against double voting
- Minimum token requirements for proposal creation
- Veto mechanism for emergency governance intervention
- Proper error handling throughout the contract

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

### Data Structures
- `proposals`: Stores proposal metadata and voting results
- `votes`: Records individual voting decisions
- `voter-power`: Manages token holder voting power and delegations
- `delegation-power`: Tracks total delegated voting power

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

## Security Considerations

- All inputs are validated to prevent malicious proposals
- Voting power is verified before allowing votes
- Double voting protection is implemented
- Delegation system prevents voting power manipulation
- Emergency veto mechanism for critical situations

## Contributing

We welcome contributions! Please see our contributing guidelines and submit pull requests for:
- Bug fixes
- Feature enhancements
- Security improvements
- Documentation updates
- Test coverage expansion

*Nebulith: Empowering decentralized communities through secure, transparent governance.*