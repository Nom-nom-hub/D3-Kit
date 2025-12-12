# Security Policy for D3-Kit

## Reporting a Vulnerability

If you discover a security vulnerability in D3-Kit, please report it responsibly using one of these methods:

### GitHub Private Security Reporting
Use GitHub's private security reporting feature: [Security Advisories](https://github.com/your-username/d3-kit/security/advisories)

### Email
Send a detailed report to: [your-security-email@example.com]

Please include the following information in your report:
- Type of vulnerability
- Location in code (file, function, etc.)
- Steps to reproduce
- Potential impact
- Suggested remediation (if known)

### Response Timeline
- Acknowledgment: Within 48 hours
- Initial assessment: Within 1 week
- Update on status: Every 2 weeks until resolution
- Fix release: As soon as possible after coordination

## Security Best Practices

### When Using D3-Kit
- Keep D3-Kit updated to the latest version
- Review generated code before using in production
- Use D3-Kit in trusted development environments only
- Be cautious of code generation from untrusted prompts

### When Contributing
- Follow secure coding practices
- Run security checks before submitting PRs
- Review dependencies for known vulnerabilities
- Use dependency scanning tools

## Supported Versions

| Version | Supported          | Notes                     |
| ------- | ------------------ | ------------------------- |
| 1.x     | ✅ Yes             | Current major version     |
| < 1.0   | ❌ No              | Legacy versions           |

## Security Considerations

D3-Kit is designed for development environments and has these security considerations:

- Does not store sensitive information by default
- Works with local files only
- Does not make network requests in basic usage
- Generated code should be reviewed before production use

## Dependencies
D3-Kit uses standard Python packages (typer, rich). Monitor for dependency security updates via your package manager.

## Disclosure Policy
We follow a coordinated disclosure approach:
1. Acknowledge report
2. Investigate and confirm vulnerability
3. Develop and test fix
4. Coordinate release with reporters if requested
5. Public disclosure with credit to reporter (if desired)