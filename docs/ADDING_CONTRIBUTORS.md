# How to Add Contributors to Flameborn Genesis Repository

This guide explains different ways to add and recognize contributors to the Flameborn Genesis project.

## Table of Contents
1. [Recognizing Contributions (All Contributors Bot)](#recognizing-contributions-all-contributors-bot)
2. [Adding GitHub Collaborators](#adding-github-collaborators)
3. [Managing Team Members](#managing-team-members)
4. [Best Practices](#best-practices)

---

## 1. Recognizing Contributions (All Contributors Bot)

The **All Contributors** specification helps recognize ALL contributions, not just code.

### Automatic Method (Using the Bot)

1. **In a PR or Issue**, comment:
   ```
   @all-contributors please add @username for code, docs, design
   ```

2. **The bot will**:
   - Create a PR updating `.all-contributorsrc`
   - Update the Contributors section in README.md
   - Add the contributor with appropriate emoji badges

3. **Merge the bot's PR** to finalize the addition

### Manual Method (Without Bot)

1. **Install all-contributors CLI** (optional, for maintainers):
   ```bash
   npm install --save-dev all-contributors-cli
   ```

2. **Add a contributor**:
   ```bash
   npx all-contributors add username code,docs,design
   ```

3. **Generate the contributors table**:
   ```bash
   npx all-contributors generate
   ```

4. **Commit and push the changes**:
   ```bash
   git add .
   git commit -m "docs: add @username as a contributor"
   git push
   ```

### Contribution Types

Common contribution types include:

| Emoji | Type | Represents |
|-------|------|------------|
| 💻 | `code` | Code contributions |
| 📖 | `doc` | Documentation |
| 🎨 | `design` | Design contributions |
| 🤔 | `ideas` | Ideas and planning |
| 🐛 | `bug` | Bug reports |
| 🛡️ | `security` | Security reports |
| 🌍 | `translation` | Translation |
| ✅ | `test` | Tests |
| 👀 | `review` | Reviewing Pull Requests |
| 🚧 | `maintenance` | Maintenance |
| 💬 | `question` | Answering Questions |
| 📢 | `talk` | Talks and presentations |
| 💡 | `example` | Examples |
| 📝 | `blog` | Blogposts |
| 🔧 | `tool` | Tools |
| 💵 | `financial` | Financial support |

For the complete list, see: https://allcontributors.org/docs/en/emoji-key

---

## 2. Adding GitHub Collaborators

For contributors who need **write access** to the repository:

### Step-by-Step (Repository Owner/Admin Only)

1. **Go to Repository Settings**:
   - Navigate to: `https://github.com/Mo-101/flameborn-genesis/settings`
   - Click on "Collaborators and teams" in the left sidebar

2. **Add a Collaborator**:
   - Click the "Add people" button
   - Enter the GitHub username or email
   - Select permission level:
     - **Read**: Can view and clone the repository
     - **Triage**: Can manage issues and pull requests
     - **Write**: Can push to the repository
     - **Maintain**: Can manage the repository without access to sensitive settings
     - **Admin**: Full access to the repository

3. **Send Invitation**:
   - Click "Add [username] to this repository"
   - The user will receive an email invitation

4. **User Accepts**:
   - The contributor must accept the invitation to gain access

### Recommended Permission Levels

| Role | Permission Level | Use Case |
|------|-----------------|----------|
| Core Team | **Admin** or **Maintain** | Long-term maintainers |
| Active Contributors | **Write** | Regular contributors who submit PRs frequently |
| Community Moderators | **Triage** | Help manage issues and discussions |
| External Contributors | **Fork & PR** | Submit changes via Pull Requests (no special access needed) |

---

## 3. Managing Team Members

For organizations with multiple repositories:

### Creating Teams (Organization Only)

If Flameborn Genesis moves to an organization:

1. **Go to Organization Settings**:
   - Navigate to your organization page
   - Click "Teams"

2. **Create a New Team**:
   - Click "New team"
   - Enter team name (e.g., "Core Developers", "Documentation", "Security")
   - Set visibility (visible or secret)

3. **Add Team Members**:
   - Add members to the team
   - Set team permissions for specific repositories

4. **Assign Team to Repositories**:
   - Go to team settings
   - Add repository access
   - Set permission level

---

## 4. Best Practices

### Security Considerations

- ✅ **DO**: Grant minimum necessary permissions
- ✅ **DO**: Regularly review collaborator list
- ✅ **DO**: Use branch protection rules for main branch
- ✅ **DO**: Require 2FA for all collaborators with write access
- ❌ **DON'T**: Share admin access unless absolutely necessary
- ❌ **DON'T**: Add collaborators you don't know personally

### Onboarding New Contributors

1. **Welcome them**: Send a welcome message with links to documentation
2. **Share context**: Point them to [CONTRIBUTING.md](CONTRIBUTING.md)
3. **Set expectations**: Clarify their role and responsibilities
4. **Provide resources**: Share development environment setup instructions
5. **Assign mentors**: For major contributors, pair them with experienced team members

### Recognizing Contributions

1. **Acknowledge quickly**: Respond to PRs and issues promptly
2. **Be specific**: Thank contributors for specific improvements
3. **Add to all-contributors**: Make sure everyone is recognized
4. **Share updates**: Mention contributors in release notes
5. **Promote sovereignty**: Emphasize how contributions support African communities

### Communication Channels

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Pull Requests**: For code reviews and feedback
- **Email**: `support@flameborn.org` for private matters
- **Discord**: [Flameborn Community](https://discord.gg/flamecommunity) for real-time chat

---

## Quick Reference: Adding a Contributor

### For Recognition Only:
```bash
# Comment on PR or issue:
@all-contributors please add @username for code, docs
```

### For Write Access:
```
GitHub Settings → Collaborators → Add people → Select permission → Send invitation
```

### Both:
```bash
# 1. Add as collaborator on GitHub (Settings → Collaborators)
# 2. Then add to contributors list:
@all-contributors please add @username for code
```

---

## Need Help?

- Check the [all-contributors documentation](https://allcontributors.org/)
- See [GitHub's collaborator documentation](https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-access-to-your-personal-repositories/inviting-collaborators-to-a-personal-repository)
- Contact the repository owner: Akanimo Iniobong ([@Mo-101](https://github.com/Mo-101))

---

**Remember**: Every contributor, regardless of their contribution type, helps Flameborn achieve its mission of African sovereignty in humanitarian technology. Recognize and welcome all contributions! ❤️
