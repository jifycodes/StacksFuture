# StacksFutures

A decentralized perpetual futures protocol built on the Stacks blockchain, enabling leveraged trading of BTC-USD pairs with isolated margin and comprehensive risk management.

## 🎯 Overview

StacksFutures is a DeFi protocol that brings perpetual futures trading to Bitcoin through the Stacks network. Users can open leveraged long or short positions on BTC-USD with STX as collateral, featuring automated liquidations, real-time position health monitoring, and decentralized price feeds.

## ✨ Key Features

### 🔒 **Isolated Margin System**
- Each position maintains separate collateral
- Customizable leverage up to 10x
- Risk contained per position
- Clear margin requirements and health ratios

### 📊 **Comprehensive Position Management**
- **Long/Short Positions**: Trade both directions on BTC-USD
- **Real-time P&L**: Continuous profit/loss calculation
- **Health Monitoring**: Live margin ratio and liquidation price tracking
- **Flexible Sizing**: Open positions of any size (subject to collateral)

### ⚡ **Automated Liquidation Engine**
- **Decentralized Liquidations**: Anyone can trigger liquidations
- **Liquidator Incentives**: 2.5% reward for liquidating underwater positions
- **Price-based Triggers**: Automatic execution when positions hit liquidation price
- **Capital Protection**: Prevents total loss through timely liquidations

### 💰 **Collateral & Fee System**
- **STX Collateral**: Native Stacks token as margin
- **Competitive Fees**: 0.2% taker fee on position changes
- **Transparent Accounting**: All balances and fees clearly tracked
- **Instant Deposits/Withdrawals**: Subject to margin requirements

### 🛡️ **Risk Management**
- **Maintenance Margin**: 5% minimum to avoid liquidation
- **Initial Margin**: 10% minimum to open positions
- **Leverage Limits**: Maximum 10x leverage
- **Admin Controls**: Configurable risk parameters via timelock

## 🏗️ Technical Architecture

### Smart Contract Structure
```
contracts/
└── perpetuals.clar          # Main perpetual futures contract
```

### Core Data Models

#### Position Structure
```clarity
{
  size: uint,              // Position size in USD
  side: bool,              // true=long, false=short  
  entry-price: uint,       // Entry price with 6 decimal precision
  collateral: uint,        // Collateral amount in STX
  timestamp: uint,         // Opening block height
  leverage: uint           // Leverage multiplier (1-10x)
}
```

#### Health Tracking
```clarity
{
  margin-ratio: uint,      // Current margin percentage
  liquidation-price: uint, // Liquidation trigger price
  unrealized-pnl: int      // Current profit/loss
}
```

## 📖 Usage Guide

### For Traders

#### 1. Deposit Collateral
```clarity
(contract-call? .perpetuals deposit-collateral u1000000) ;; 1 STX
```

#### 2. Open Position
```clarity
;; Open 10x long position on BTC-USD
(contract-call? .perpetuals open-position u5000000000 true u10)
;; Parameters: size-in-USD, is-long, leverage
```

#### 3. Monitor Position
```clarity
;; Check position details
(contract-call? .perpetuals get-user-position 'SP123...)

;; Check health metrics  
(contract-call? .perpetuals get-position-health 'SP123...)
```

#### 4. Close Position
```clarity
(contract-call? .perpetuals close-position)
```

#### 5. Withdraw Funds
```clarity
(contract-call? .perpetuals withdraw-collateral u500000) ;; 0.5 STX
```

### For Liquidators

#### Monitor Positions
```clarity
;; Check if position can be liquidated
(contract-call? .perpetuals can-liquidate 'SP123... u4400000000)
```

#### Execute Liquidation
```clarity
;; Liquidate underwater position for reward
(contract-call? .perpetuals liquidate-position 'SP123...)
```

### For Price Oracle Operators

#### Update Market Price
```clarity
(contract-call? .perpetuals update-price u4550000000) ;; $45,500
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet v3.5.0+](https://github.com/hirosystems/clarinet)
- Node.js 18+
- Git

### Installation
```bash
# Clone repository
git clone https://github.com/your-org/StacksFutures
cd StacksFutures

# Install Clarinet
curl -L https://github.com/hirosystems/clarinet/releases/download/v3.5.0/clarinet-linux-x64.tar.gz | tar xz
sudo mv clarinet /usr/local/bin/

# Initialize project
clarinet new StacksFutures
cd StacksFutures

# Add contract
clarinet contract new perpetuals
```

### Testing
```bash
# Run contract tests
clarinet test

# Start local devnet
clarinet devnet start

# Check contract
clarinet check
```

### Deployment
```bash
# Deploy to devnet
clarinet deploy --devnet

# Deploy to testnet  
clarinet deploy --testnet

# Deploy to mainnet
clarinet deploy --mainnet
```

## 🧪 Testing & Validation

### Unit Tests
- Position opening/closing logic
- Liquidation trigger conditions  
- Fee calculation accuracy
- Balance accounting verification
- Edge case handling

### Integration Tests
- Full trade lifecycle workflows
- Cross-function interaction validation
- Oracle price update scenarios
- Administrative function testing

### Security Considerations
- **Reentrancy Protection**: State updates before external calls
- **Integer Overflow Protection**: Safe arithmetic operations
- **Access Control**: Admin functions restricted to contract owner
- **Input Validation**: All parameters validated before processing

## 📊 Market Parameters

| Parameter | Value | Description |
|-----------|--------|-------------|
| **Maintenance Margin** | 5% | Minimum margin to avoid liquidation |
| **Initial Margin** | 10% | Minimum margin to open position |
| **Max Leverage** | 10x | Maximum allowed leverage |
| **Liquidation Incentive** | 2.5% | Reward for liquidating positions |
| **Taker Fee** | 0.2% | Fee on position changes |
| **Price Precision** | 6 decimals | Price representation accuracy |

## 🚀 Roadmap

### Phase 1 - MVP ✅
- [x] Single BTC-USD market
- [x] Isolated margin positions
- [x] Basic liquidation engine
- [x] STX collateral support
- [x] Admin risk controls

### Phase 2 - Enhancement
- [ ] Oracle integration with signed feeds
- [ ] Funding rate mechanism
- [ ] Position health APIs
- [ ] Liquidation bot incentives

### Phase 3 - Scale
- [ ] Cross-margin support
- [ ] Multiple trading pairs
- [ ] Advanced order types
- [ ] Insurance fund

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Process
1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request
5. Code review and merge

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🛠️ Support & Documentation

- **Documentation**: [docs.StacksFutures.com](https://docs.StacksFutures.com)
- **Discord**: [Join our community](https://discord.gg/StacksFutures)  
- **Twitter**: [@StacksFutures](https://twitter.com/StacksFutures)
- **Email**: support@StacksFutures.com

## ⚠️ Risk Disclosure

Perpetual futures trading involves significant financial risk. Leveraged positions can result in rapid losses exceeding your initial investment. Only trade with capital you can afford to lose. This protocol is experimental software - use at your own risk.

---

**Built with ❤️ on Stacks • Powered by Bitcoin**
