# Contributing to D3-Kit

Thank you for your interest in contributing to D3-Kit! We welcome contributions from the community and are grateful for your help in improving the framework.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming environment for everyone.

## How to Contribute

### Reporting Issues

- Use the issue tracker to report bugs or suggest features
- Check if the issue already exists before creating a new one
- Provide detailed information to help us understand and reproduce the issue

### Pull Requests

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes following the project's coding standards
4. Add or update tests as appropriate
5. Update documentation if needed
6. Submit a pull request with a clear description of your changes

### Development Setup

1. Clone your fork:
   ```bash
   git clone https://github.com/your-username/d3-kit.git
   cd d3-kit
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install in development mode:
   ```bash
   pip install -e .
   pip install pytest black flake8 mypy
   ```

### Testing

Run the tests to make sure your changes don't break anything:

```bash
pytest
```

For code formatting and linting:

```bash
black src/
flake8 src/
mypy src/
```

## Development Workflow

D3-Kit follows a feature-driven development approach similar to the one used by D3-Kit itself:

1. **Identify**: Find an issue or feature to work on
2. **Specify**: Create a clear specification of what you'll implement
3. **Plan**: Plan the technical approach
4. **Implement**: Write the code
5. **Validate**: Test and verify your implementation

## Code Standards

- Follow PEP 8 style guidelines
- Write clear, descriptive commit messages
- Include docstrings for functions and classes
- Add type hints where appropriate
- Keep functions focused and reasonably sized

## D3-Kit Specific Guidelines

When contributing to D3-Kit, keep in mind:

- D3-Kit is designed for developer intent-first development
- Maintain the parallel exploration capability ([P] markers)
- Ensure all templates are AI-optimized for code generation
- Follow the D3 command structure (/d3.intend, /d3.plan, etc.)
- Maintain regeneration-friendly artifacts

## Getting Help

If you need help or have questions, feel free to:

- Open an issue
- Join our community discussions
- Check the documentation

Thank you for contributing to D3-Kit!