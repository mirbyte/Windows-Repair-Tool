# Windows System Repair Tool

A comprehensive batch script for diagnosing and repairing Windows system issues. This tool provides an interactive menu-driven interface to execute various Windows system maintenance and repair commands.

![Administrator Shield](https://img.shields.io/badge/requires-administrator-blue)
![Windows Support](https://img.shields.io/badge/platform-Windows-brightgreen)
![Batch Script](https://img.shields.io/badge/language-Batch-orange)

## 🔍 Features

- **Quick Status Check**: Rapid system image integrity verification
- **Detailed System Scan**: In-depth analysis of system image health
- **System Image Repair**: Automated repair of corrupted system files with Windows Update integration
- **System File Checker**: Comprehensive system file integrity verification and repair
- **Windows Update Repair**: Advanced troubleshooting for Windows Update issues including:
  - Service management
  - Component re-registration
  - Network reset
  - Driver cleanup
- **All-in-One Option**: Sequential execution of all repair operations
- **Interactive Menu**: User-friendly interface with detailed help section

## 🚀 Getting Started

### Prerequisites

- Windows Operating System (Windows 10/11 recommended)
- Administrator privileges
- Active internet connection (for system file downloads during repairs)

### Installation

1. Download the `sys_repair.bat` file
2. Right-click the file and select "Run as administrator"

```batch
# Alternative: Launch from Command Prompt (Admin)
cd path/to/script
sys_repair.bat
```

## 💻 Usage

The script presents an interactive menu with the following options:

1. **Quick Status Check** (`DISM /CheckHealth`)

   - Fast verification of system image integrity
   - Recommended as first diagnostic step

2. **Detailed Scan** (`DISM /ScanHealth`)

   - Thorough system image analysis
   - May take several minutes to complete

3. **Repair System Image** (`DISM /RestoreHealth`)

   - Attempts to repair corrupted system files
   - Downloads replacement files if needed
   - Can take 15-30 minutes depending on system state

4. **System File Checker** (`sfc /scannow`)

   - Scans and repairs corrupted Windows system files
   - Recommended after DISM repairs

5. **System Update Repair**

   - Comprehensive Windows Update troubleshooting
   - Resets update-related services and components
   - Cleans up driver cache
   - Repairs network settings

6. **Run All Sequentially**
   - Executes all repair operations in optimal order
   - Recommended for thorough system maintenance

## ⚠️ Important Notes

- **Always backup important data** before running system repairs
- **Requires administrator privileges** to execute repairs
- Some operations may require system restart
- Windows Update repairs may temporarily disable update services
- Internet connection required for downloading system files during repair

## 🔧 Technical Details

The script performs the following technical operations:

- DISM (Deployment Image Servicing and Management) operations
- System File Checker (SFC) scans
- Service management (stop/start) for:
  - Background Intelligent Transfer Service (BITS)
  - Windows Update Service
  - MSI Installer
  - Cryptographic Services
  - Application Identity Service
- Registry component re-registration
- Network stack reset
- Driver state management
- Windows component cleanup

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔍 Troubleshooting

If you encounter issues:

1. Ensure you're running as administrator
2. Check internet connectivity for file downloads
3. Verify Windows Update service is accessible
4. Check system drive for sufficient space
5. Review logs in `%windir%\Logs\DISM\dism.log`
