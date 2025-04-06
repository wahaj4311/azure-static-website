# Azure Static Website Hosting

This project demonstrates how to host a static website using Azure Storage's static website hosting feature.

## Prerequisites

- Azure CLI installed and configured
- Azure subscription
- GitHub account
- Node.js and npm (if using a modern static site generator)

## Project Structure

```
.
├── README.md
├── website/              # Static website content
├── infrastructure/       # Azure infrastructure scripts
└── docs/                # Additional documentation
```

## Quick Start

1. Clone this repository
2. Deploy Azure infrastructure:
   ```bash
   cd infrastructure
   ./deploy-infrastructure.sh
   ```
3. Deploy website content:
   ```bash
   cd website
   ./deploy-content.sh
   ```

## Azure Resources Created

- Azure Storage Account (with static website hosting enabled)
- Secure HTTPS endpoint
- Custom error pages

## Documentation

Detailed documentation can be found in the [docs](./docs) directory:
- [Infrastructure Setup](./docs/infrastructure-setup.md)
- [Content Deployment](./docs/content-deployment.md)

## Features

- Static website hosting using Azure Storage
- Secure HTTPS access
- Custom error pages
- Easy deployment scripts
- Cost-effective hosting solution
- Scalable storage platform

## Deployment

The project includes two main deployment scripts:

1. `infrastructure/deploy-infrastructure.sh`: Sets up Azure resources
2. `website/deploy-content.sh`: Deploys website content

Both scripts include:
- Clear output with color-coded messages
- Error handling
- Configuration management
- Automatic resource naming

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 