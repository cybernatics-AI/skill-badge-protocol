# Skill Badge Protocol

A decentralized reputation system built on the Stacks blockchain that allows users to mint skill-based NFT badges, earn verifiable credentials, and build on-chain professional reputations through community endorsements.

##  Overview

The Skill Badge Protocol transforms how professional skills are verified and showcased in the decentralized world. Users can mint NFT badges representing specific skills (coding, design, writing, etc.) by completing verifiable challenges or receiving endorsements from other community members. The system incentivizes honest verification through a staking mechanism where accurate endorsements are rewarded and false endorsements result in token slashing.

##  Features

### Core Functionality
- **Skill-Based NFT Badges**: Mint unique badges representing various professional skills
- **Verifiable Challenges**: Complete on-chain challenges to earn badges automatically
- **Community Endorsements**: Stake STX tokens to endorse other users' skills
- **Reputation Scoring**: Dynamic reputation system based on badge quality and endorsements
- **Marketplace Integration**: Showcase badge collections and credentials
- **Employer Verification**: On-chain credential verification for hiring and collaboration

### Economic Incentives
- **Staking Rewards**: Earn rewards for accurate skill endorsements
- **Slashing Protection**: False endorsements result in stake slashing
- **Token Economics**: STX-based staking and reward system
- **Governance Participation**: Vote on new skill categories and protocol updates

### Technical Features
- **Smart Contract Automation**: Automated badge minting and verification
- **Metadata Standards**: Rich metadata for achievement levels and verification methods
- **Governance System**: Decentralized decision-making for protocol evolution
- **Interoperability**: Compatible with existing Stacks ecosystem tools

##  Usage Examples

### Minting a Skill Badge

```clarity
;; Mint a coding skill badge after completing a challenge
(contract-call? .skill-badge-nft mint-challenge-badge 
  "coding" 
  u1 ;; skill level (1-5)
  "completed-rust-challenge-001"
  { description: "Advanced Rust Programming", 
    challenge-hash: "0x..." })
```

### Endorsing Another User's Skill

```clarity
;; Stake 100 STX to endorse a user's design skills
(contract-call? .endorsement-system stake-endorsement 
  'SP1ABC...XYZ ;; endorsee principal
  "design" 
  u100000000) ;; 100 STX in microSTX
```

### Querying Badge Information

```clarity
;; Get all badges owned by a user
(contract-call? .skill-badge-nft get-user-badges 'SP1ABC...XYZ)

;; Get reputation score
(contract-call? .reputation-system get-reputation-score 'SP1ABC...XYZ)
```

### Governance Voting

```clarity
;; Vote on adding a new skill category
(contract-call? .governance vote-on-proposal 
  u1 ;; proposal ID
  true) ;; vote (true/false)
```

##  Smart Contract Overview

### Core Contracts

#### `skill-badge-nft.clar`
- **Purpose**: NFT contract for skill badges
- **Key Functions**:
  - `mint-challenge-badge`: Mint badges through automated challenges
  - `mint-endorsed-badge`: Mint badges through community endorsement
  - `get-badge-metadata`: Retrieve badge information and verification data
  - `transfer-badge`: Transfer badge ownership

#### `endorsement-system.clar`
- **Purpose**: Handles staking and endorsement mechanics
- **Key Functions**:
  - `stake-endorsement`: Stake STX to endorse a skill
  - `verify-endorsement`: Verify and process endorsement results
  - `claim-rewards`: Claim rewards for successful endorsements
  - `slash-stake`: Slash stakes for false endorsements

#### `reputation-system.clar`
- **Purpose**: Calculates and maintains user reputation scores
- **Key Functions**:
  - `calculate-reputation`: Compute reputation based on badges and endorsements
  - `update-skill-level`: Update skill proficiency levels
  - `get-reputation-history`: Retrieve reputation change history

#### `governance.clar`
- **Purpose**: Decentralized governance for protocol updates
- **Key Functions**:
  - `propose-skill-category`: Propose new skill categories
  - `vote-on-proposal`: Participate in governance voting
  - `execute-proposal`: Execute approved proposals

#### `marketplace.clar`
- **Purpose**: Badge marketplace and showcase functionality
- **Key Functions**:
  - `list-profile`: Create professional profile with badges
  - `verify-credentials`: Verify user credentials for employers
  - `search-skills`: Search users by skill categories


##  Contributing

We welcome contributions from the community! Here's how to get started:

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow the coding standards outlined in `.editorconfig`
4. Write tests for new functionality
5. Ensure all tests pass: `clarinet test`
6. Submit a pull request

### Coding Standards

- Use clear, descriptive variable names
- Follow Clarity best practices for smart contracts
- Include comprehensive test coverage (>90%)
- Document public functions with docstrings
- Follow the existing code style and formatting

### Reporting Issues

- Use GitHub Issues for bug reports and feature requests
- Provide detailed reproduction steps for bugs
- Include relevant contract addresses and transaction IDs
- Label issues appropriately (bug, enhancement, documentation, etc.)

### Pull Request Process

1. Update documentation for any new features
2. Add tests for new functionality
3. Ensure CI checks pass
4. Request review from maintainers
5. Address feedback and re-request review
