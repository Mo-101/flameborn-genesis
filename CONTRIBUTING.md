# Contributing to Flameborn Genesis

Thank you for your interest in contributing to Flameborn! We welcome contributions from everyone who shares our mission to eliminate disease outbreaks in Africa through decentralized, transparent humanitarian technology.

## 🌍 Our Mission

Flameborn is built on the principle of **African sovereignty** - ensuring that African communities have full control and ownership over humanitarian efforts that affect them. All contributions should align with this core value.

## 🤝 Code of Conduct

By participating in this project, you agree to:
- Treat all community members with respect and dignity
- Support African sovereignty and community-led decision making
- Maintain transparency in all contributions
- Prioritize the needs of end users (health workers and donors in Africa)
- Avoid introducing barriers that could limit accessibility in low-resource environments

## 🚀 How to Contribute

### For Code Contributors

#### 1. Fork and Clone the Repository

```bash
git clone https://github.com/Mo-101/flameborn-genesis.git
cd flameborn-genesis
```

#### 2. Set Up Your Development Environment

**Prerequisites:**
- Node.js v16 or higher
- npm
- Git

**Install Dependencies:**
```bash
npm install
```

**Configure Environment:**
Create a `.env` file based on `.env.example`:
```bash
cp .env.example .env
```

Edit `.env` with your configuration:
```
PRIVATE_KEY=your_ethereum_private_key_here
CELO_ALFAJORES_RPC_URL=https://alfajores-forno.celo-testnet.org
CELO_MAINNET_RPC_URL=https://forno.celo.org
```

#### 3. Compile Smart Contracts

```bash
npx hardhat compile
```

#### 4. Run Tests

```bash
npm test
```

Make sure all tests pass before making changes.

#### 5. Create a Branch

Create a descriptive branch for your work:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

#### 6. Make Your Changes

- Write clean, readable code
- Follow existing code style and conventions
- Add comments where necessary (especially for complex logic)
- Ensure your code works in low-bandwidth environments when applicable
- Test thoroughly on both Alfajores testnet and locally

#### 7. Test Your Changes

Run the test suite to ensure nothing breaks:
```bash
npm test
```

If you've added new functionality, add appropriate tests.

#### 8. Commit Your Changes

Write clear, descriptive commit messages:
```bash
git add .
git commit -m "feat: add feature description"
# or
git commit -m "fix: bug description"
```

**Commit Message Format:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Adding or updating tests
- `refactor:` - Code refactoring
- `chore:` - Maintenance tasks

#### 9. Push and Create a Pull Request

```bash
git push origin your-branch-name
```

Then go to GitHub and create a Pull Request with:
- A clear title describing the change
- A detailed description of what was changed and why
- Reference to any related issues (e.g., "Fixes #123")
- Screenshots or examples if applicable

### For Non-Code Contributors

You can contribute in many ways:

#### Documentation
- Improve existing documentation
- Translate documentation to African languages
- Create tutorials or guides
- Document use cases or success stories

#### Community Support
- Help answer questions in discussions
- Test the platform and report bugs
- Share feedback from African communities
- Help onboard new validators or health workers

#### Design
- Improve UI/UX designs
- Create graphics or visual assets
- Design for low-bandwidth and feature phone compatibility

#### Testing
- Test on different devices and networks
- Report bugs with detailed reproduction steps
- Test in real-world African connectivity conditions

## 📋 Development Guidelines

### Smart Contract Development

- Follow Solidity best practices and security standards
- Use OpenZeppelin libraries where possible
- Add comprehensive natspec comments
- Ensure gas efficiency (important for users in Africa)
- Test on Alfajores testnet before mainnet deployment
- Consider African identity verification requirements in all features

### Linting

Run the Solidity linter before committing:
```bash
npx solhint 'contracts/**/*.sol'
```

### Code Review Process

1. All PRs require at least one review
2. Address all feedback promptly
3. Keep PRs focused and reasonably sized
4. Ensure CI/CD checks pass
5. Maintainers will merge approved PRs

## 🔒 Security

- **Never commit private keys or sensitive data**
- Report security vulnerabilities privately to `support@flameborn.org`
- See [SECURITY.md](SECURITY.md) for our security policy
- Follow secure coding practices
- Be mindful of African identity data protection

## 🎯 Priority Areas

We especially welcome contributions in:

1. **African Identity Verification** - Improving verification methods that respect privacy and sovereignty
2. **Low-Bandwidth Optimization** - Making the platform work in limited connectivity environments
3. **USSD Integration** - Feature phone accessibility
4. **Localization** - Supporting African languages
5. **Testing** - Expanding test coverage
6. **Documentation** - Making the project more accessible
7. **Gas Optimization** - Reducing transaction costs for African users

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Email**: `support@flameborn.org`
- **Discord**: [Flameborn Community](https://discord.gg/flamecommunity)

## 🙏 Recognition

We use the [All Contributors](https://allcontributors.org/) specification to recognize all contributors. Every contribution matters, whether it's code, documentation, design, or community support.

To add yourself as a contributor, comment on your PR:
```
@all-contributors please add @username for code, docs
```

Valid contribution types: code, doc, design, test, bug, security, translation, review, ideas, content, and more.

**For maintainers**: See [docs/ADDING_CONTRIBUTORS.md](docs/ADDING_CONTRIBUTORS.md) for a comprehensive guide on managing contributors and collaborators.

## 📜 License

By contributing to Flameborn Genesis, you agree that your contributions will be licensed under the MIT License.

---

## ❤️ Thank You

Your contribution helps save lives and supports African sovereignty in humanitarian efforts. Every line of code, every bug report, every suggestion brings us closer to a world where health crises in Africa are met with fast, transparent, and effective responses.

**"Life is Simple. Only Decide."** — Thank you for deciding to contribute to Flameborn.
