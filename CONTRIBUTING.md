# Contributing to FormStack

Thank you for your interest in contributing to FormStack! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
- Use the [GitHub issue tracker](https://github.com/your-org/formstack/issues)
- Search existing issues before creating new ones
- Provide detailed information about the issue
- Include steps to reproduce the problem

### Suggesting Features
- Use the [GitHub discussions](https://github.com/your-org/formstack/discussions) for feature requests
- Describe the use case and benefits
- Consider implementation complexity

### Code Contributions
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Git

### Setup Steps
```bash
# Clone your fork
git clone https://github.com/your-username/formstack.git
cd formstack

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example app
cd example
flutter run
```

## 📝 Coding Standards

### Code Style
- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Testing
- Write unit tests for new features
- Test edge cases and error conditions
- Maintain test coverage above 80%

### Documentation
- Update README.md for new features
- Add inline documentation for public APIs
- Update examples when adding new input types

## 🚀 Pull Request Process

### Before Submitting
- [ ] Code follows project conventions
- [ ] Tests pass (`flutter test`)
- [ ] No linter errors (`flutter analyze`)
- [ ] Documentation updated
- [ ] Example app works with changes

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Example app tested

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## 🏗️ Project Structure

```
lib/
├── src/
│   ├── core/           # Core form logic
│   ├── ui/             # UI components
│   ├── result/         # Validation and results
│   ├── step/           # Step definitions
│   └── utils/          # Utilities
example/                 # Example application
test/                    # Unit tests
docs/                    # Documentation
```

## 🧪 Testing Guidelines

### Unit Tests
- Test individual functions and methods
- Mock external dependencies
- Test both success and failure cases

### Widget Tests
- Test widget rendering
- Test user interactions
- Test form validation

### Integration Tests
- Test complete form flows
- Test with different input types
- Test error handling

## 📋 Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `question` - Further information requested

## 🎯 Areas for Contribution

### High Priority
- Additional input types
- Performance optimizations
- Accessibility improvements
- Documentation enhancements

### Medium Priority
- New validation rules
- UI theme improvements
- Example applications
- Testing utilities

### Low Priority
- Code refactoring
- Minor bug fixes
- Documentation updates

## 💬 Communication

- Use GitHub issues for bug reports
- Use GitHub discussions for questions
- Be respectful and constructive
- Follow the code of conduct

## 📜 License

By contributing to FormStack, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for contributing to FormStack! 🚀
