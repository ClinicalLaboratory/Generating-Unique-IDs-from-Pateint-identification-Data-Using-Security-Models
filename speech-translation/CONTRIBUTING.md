# Contributing to Real-time Speech Translation System

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/speech-translation.git
   cd speech-translation
   ```
3. **Set up the development environment**:
   ```bash
   ./start.sh
   ```

## 🛠️ Development Setup

### Prerequisites
- Docker Desktop
- Git
- Modern web browser
- Python 3.11+ (for local development)

### Local Development
```bash
# Install dependencies
bash setup.sh

# Run tests
python3 test-config.py

# Start services individually for development
source .venv/bin/activate
uvicorn scripts.transcribe_translate_service:app --reload --port 8001
```

## 📝 Making Changes

### Code Style
- **Python**: Follow PEP 8 guidelines
- **JavaScript**: Use ES6+ features, consistent indentation
- **HTML/CSS**: Semantic HTML, mobile-first responsive design
- **Docker**: Multi-stage builds, minimal base images

### Commit Messages
Use conventional commit format:
```
feat: add support for new language
fix: resolve microphone permission issue
docs: update Surface setup guide
style: improve button hover effects
```

### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring

## 🧪 Testing

### Before Submitting
1. **Run configuration tests**:
   ```bash
   python3 test-config.py
   ```

2. **Test Docker deployment**:
   ```bash
   ./start.sh
   # Verify all services start correctly
   ./stop.sh
   ```

3. **Test web interface**:
   - Record audio functionality
   - File upload functionality
   - Translation accuracy
   - Mobile/tablet responsiveness

4. **Test on Microsoft Surface** (if available):
   - Touch interface responsiveness
   - High DPI display rendering
   - Audio quality with built-in microphone

### Test Cases
- [ ] Audio recording works in Chrome, Firefox, Edge
- [ ] File upload supports WAV, MP3, WebM formats
- [ ] Translation completes within 30 seconds
- [ ] UI is responsive on mobile/tablet
- [ ] Docker containers start without errors
- [ ] n8n workflow imports successfully

## 📋 Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** with clear, focused commits

3. **Update documentation** if needed:
   - Update README.md for new features
   - Update SURFACE_SETUP.md for Surface-specific changes
   - Add/update code comments

4. **Test thoroughly**:
   ```bash
   python3 test-config.py
   ./start.sh  # Test full deployment
   ```

5. **Submit pull request**:
   - Clear title and description
   - Reference any related issues
   - Include screenshots for UI changes
   - List testing performed

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Performance improvement
- [ ] Refactoring

## Testing
- [ ] Configuration tests pass
- [ ] Docker deployment works
- [ ] Web interface tested
- [ ] Surface compatibility verified (if applicable)

## Screenshots
(If applicable)

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🐛 Reporting Issues

### Bug Reports
Include:
- **Environment**: OS, browser, Docker version
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Screenshots/logs** if applicable
- **Surface model** if Surface-specific

### Feature Requests
Include:
- **Use case**: Why is this needed?
- **Proposed solution**: How should it work?
- **Alternatives considered**
- **Surface compatibility** considerations

## 🏷️ Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Documentation improvements
- `surface` - Microsoft Surface specific
- `docker` - Docker/deployment related
- `ui/ux` - User interface improvements
- `performance` - Performance optimizations
- `good first issue` - Good for newcomers

## 🌟 Areas for Contribution

### High Priority
- **Language support**: Add more Argos Translate language pairs
- **Performance**: Optimize Whisper model loading
- **UI/UX**: Improve accessibility and mobile experience
- **Documentation**: More detailed setup guides

### Medium Priority
- **Features**: Batch processing, audio enhancement
- **Testing**: Automated testing suite
- **Monitoring**: Health checks and metrics
- **Security**: Input validation and sanitization

### Low Priority
- **Integrations**: Additional n8n nodes
- **Themes**: Light mode, custom themes
- **Analytics**: Usage statistics (privacy-preserving)

## 🤝 Community Guidelines

- **Be respectful** and inclusive
- **Help others** learn and contribute
- **Share knowledge** and best practices
- **Focus on constructive feedback**
- **Celebrate contributions** of all sizes

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **Discussions**: For questions and general discussion
- **Documentation**: Check README.md and SURFACE_SETUP.md first

## 🎉 Recognition

Contributors will be:
- Listed in the project README
- Mentioned in release notes
- Invited to join the maintainers team (for significant contributions)

Thank you for contributing to making speech translation more accessible! 🚀