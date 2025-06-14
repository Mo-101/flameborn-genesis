# flameborn-genesis
# 🌍 Flameborn Token (FLB)

**"Life is Simple. Only Decide."** — Flameborn’s guiding motto  
A decentralized humanitarian initiative to eliminate disease outbreaks in Africa through trustless, transparent, and direct funding.

---

## 🔥 Overview

**Flameborn** is a blockchain-based system that delivers fast, traceable, and community-driven financial support to real health actors in crisis zones. Powered by the **FLB token (BEP-20)** on Binance Smart Chain, the platform automates funding and accountability using smart contracts and decentralized governance.

- Direct donor-to-HealthActor (Hospital or Mobile Clinic) funding with no intermediaries
- Smart-contract-verified health actor registry
- Every donation mints FLB tokens and triggers transparent payments

---

## 🪙 Token Summary

| Property       | Value                     |
|----------------|---------------------------|
| Token Name     | Flameborn Token           |
| Symbol         | FLB                       |
| Standard       | BEP-20 (BNB Smart Chain)  |
| Decimals       | 18                        |
| Governance     | DAO voting (1 FLB = 1 vote) |
| Initial Supply | 100 FLB (Genesis drop)    |
| Mint Logic     | 1 FLB / 1 BNB donated     |

---

## ⚙️ Smart Contracts

### `FlameBornToken.sol`
- ERC20 + Burnable + AccessControl
- `MINTER_ROLE` required to mint
- Used by `DonationRouter` to mint FLB on verified donations

### `HealthActorRegistry.sol`
- Registers verified health actors (doctors, clinics, CHWs)
- Only those listed can receive donations

### `DonationRouter.sol`
- Accepts BNB from donors
- Verifies health actor
- Transfers BNB to recipient
- Mints equivalent FLB to donor
- Uses `nonReentrant` for safety

---

## 🏛 DAO Governance

The **Flameborn DAO** gives voting rights to all FLB holders:

- Approve health actors and campaigns
- Change system parameters (minting rate, etc.)
- Propose and vote on upgrades or partnerships

> Governance = ownership = accountability.

---

## 💡 Utility of FLB

- **Governance**: Vote on DAO proposals
- **Proof of Contribution**: Track and recognize donor impact
- **Access**: Unlock tools like Mostar AI for verified users
- **Reputation**: Showcase impact in the community
- **Liquidity**: Tradable on DEXs/CEXs (pending listings)

---

## 🛡 Security Architecture

- Verified-only actors via `HealthActorRegistry`
- Reentrancy protection via `nonReentrant`
- OpenZeppelin libraries for battle-tested security
- Non-custodial design: No pooled funds, direct transfers
- DAO can pause operations or update contracts through governance

---

## 🪙 Minting Process

1. Donor selects verified health actor
2. Sends BNB via `DonationRouter`
3. Router checks actor’s verification
4. On success:
   - BNB → health actor
   - FLB → donor
   - Blockchain logs → immutable proof

All in one atomic transaction.

---

## 📊 FLB Distribution Model (Optional Future Vaults)

| Allocation Target        | Percentage |
|--------------------------|------------|
| Health Facilities (HFC)  | 80%        |
| System Upkeep            | 10%        |
| Donor Incentives         | 5%         |
| Ground & Follow-up Team  | 5%         |

*This model is used when project-specific vaults are deployed.*

---

## 🙌 How to Contribute

### For Donors
- Visit the platform
- Choose a health actor or campaign
- Send a donation
- Receive FLB in your wallet as proof

### For Health Workers
- Apply to become verified
- Get listed in `HealthActorRegistry`
- Start receiving direct global support

### For Community Members
- Spread the word
- Vote in DAO proposals
- Volunteer skills or ideas

---

## 📜 License

This project is released under the [MIT License](LICENSE).

---

## ✉️ Contact

- Website: [flameborn.org](https://flameborn.org)
- Email: `support@flameborn.org`
- Twitter: [@FlamebornDAO](https://twitter.com/flameborndao)
- Discord: [Flameborn Community](https://discord.gg/flamecommunity)

> Flameborn is The Driver. Blockchain is the Engine. Saving lives is the Destination.
