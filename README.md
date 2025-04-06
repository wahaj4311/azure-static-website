# Static Website Hosting with Azure Storage and CDN

This project demonstrates how to host a static website using Azure Storage and Azure CDN for optimal content delivery.

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

- Azure Storage Account (for static website hosting)
- Azure CDN Profile
- Azure CDN Endpoint

## Documentation

Detailed documentation can be found in the [docs](./docs) directory:
- [Infrastructure Setup](./docs/infrastructure-setup.md)
- [Content Deployment](./docs/content-deployment.md)
- [CDN Configuration](./docs/cdn-configuration.md)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 