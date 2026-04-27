#!/usr/bin/env python3
"""
Script to generate GitHub release description with automatic device detection
"""

import json
import os
from datetime import datetime

def generate_release_description(version, build_number):
    """Generate release description with device detection links"""
    
    repo_name = os.getenv('GITHUB_REPOSITORY', 'lie-shan/siakad_login')
    
    description = f"""# 🚀 SIAKAD App {version}

## 📱 **Smart Download - Automatic Device Detection**

### ⚡ **Recommended: Smart Download**
👉 **[Click here for automatic device detection & download](https://{repo_name.split('/')[0]}.github.io/{repo_name.split('/')[1]}/release/{version}/download.html)**

The system will automatically:
- ✅ Detect your device specifications
- ✅ Download the optimal APK version
- ✅ Ensure maximum performance

---

## 🎯 **Manual Download Options**

### 📊 **Device Compatibility Matrix**

| Device Category | RAM Range | Features | Download |
|----------------|-----------|----------|----------|
| 🟢 **Low-end** | < 2GB | Basic UI, optimized performance | [Download APK](https://github.com/{repo_name}/releases/download/{version}/app-arm64-v8a-low-release.apk) |
| 🔵 **Medium** | 2-4GB | Balanced features & performance | [Download APK](https://github.com/{repo_name}/releases/download/{version}/app-arm64-v8a-medium-release.apk) |
| 🟣 **High-end** | 4-8GB | Full features, rich animations | [Download APK](https://github.com/{repo_name}/releases/download/{version}/app-arm64-v8a-high-release.apk) |
| 🟡 **Premium** | > 8GB | Ultra quality, 4K support | [Download APK](https://github.com/{repo_name}/releases/download/{version}/app-arm64-v8a-premium-release.apk) |
| 🌐 **Universal** | Any | Auto-adaptive for all devices | [Download APK](https://github.com/{repo_name}/releases/download/{version}/app-release.apk) |

---

## 🔧 **Installation Instructions**

### Method 1: Automatic (Recommended)
1. Visit the smart download link above
2. Click "Download Sekarang" 
3. System automatically detects your device
4. Download starts automatically

### Method 2: Manual Selection
1. Check your device RAM in Settings > About Phone
2. Choose the appropriate version from the table above
3. Download and install the APK

### Method 3: QR Code
1. Download the [smart-download.html](https://github.com/{repo_name}/releases/download/{version}/smart-download.html)
2. Open in browser on desktop
3. Scan QR code with your phone
4. Download starts automatically

---

## 📋 **System Requirements**

### Minimum Requirements
- **Android**: 5.0 (Lollipop) or higher
- **RAM**: 1GB minimum, 2GB recommended
- **Storage**: 100MB free space + cache
- **Network**: Internet connection for setup

### Recommended Requirements
- **Android**: 8.0 (Oreo) or higher
- **RAM**: 4GB or more
- **Storage**: 500MB free space
- **Network**: Stable internet connection

---

## ✨ **What's New in {version}**

### 🎯 **Automatic Device Optimization**
- **Smart Detection**: Automatically analyzes device capabilities on first launch
- **Adaptive Assets**: Downloads optimized images, videos, and content
- **Performance Scaling**: Adjusts UI complexity based on device performance
- **Intelligent Caching**: Smart cache management based on available storage

### 🔧 **Technical Improvements**
- Enhanced memory management for low-end devices
- Improved download reliability with retry logic
- Better battery optimization
- Faster app startup times
- Reduced network data usage

### 🎨 **UI/UX Enhancements**
- Adaptive layouts for all screen sizes
- Smooth animations on capable devices
- Improved accessibility features
- Better dark mode support

---

## 🐛 **Bug Fixes**
- Fixed crashes on devices with < 2GB RAM
- Resolved download timeout issues
- Improved error handling and user feedback
- Better memory leak prevention

---

## 📱 **Device-Specific Optimizations**

### Low-end Devices (< 2GB RAM)
- Reduced animation complexity
- Lower resolution images by default
- Simplified UI elements
- Aggressive memory management

### Medium Devices (2-4GB RAM)
- Balanced feature set
- Standard image quality
- Smooth transitions
- Efficient caching

### High-end Devices (4-8GB RAM)
- Full feature availability
- High-resolution assets
- Rich animations
- Extended cache duration

### Premium Devices (> 8GB RAM)
- Ultra-high quality assets
- 4K video support
- Advanced animations
- Maximum cache size

---

## 🔄 **Update Process**

The app automatically:
1. Detects device capabilities on first launch
2. Downloads appropriate assets
3. Optimizes settings for performance
4. Manages cache efficiently

---

## 📞 **Support & Feedback**

- 📧 **Email**: support@siakad.app
- 💬 **WhatsApp**: +62 812-3456-7890
- 🐛 **Issues**: [Report Bug](https://github.com/{repo_name}/issues/new?template=bug_report.md)
- 💡 **Features**: [Request Feature](https://github.com/{repo_name}/issues/new?template=feature_request.md)

---

## 📊 **Build Information**

- **Version**: {version}
- **Build Number**: {build_number}
- **Build Date**: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S UTC')}
- **Flutter Version**: 3.19.0
- **Target Platforms**: Android 5.0+ (ARM64, ARMv7)
- **Architecture**: Optimized for each performance tier

---

## 🔒 **Security & Privacy**

- ✅ No personal data collected without consent
- ✅ Secure API communication with encryption
- ✅ Local data storage with device encryption
- ✅ Regular security updates
- ✅ Privacy policy compliance

---

## 🌟 **Enjoy the Optimized Experience!**

This release brings **intelligent device optimization** that ensures the best possible performance on your specific device. Whether you're using a budget phone or a flagship device, SIAKAD will automatically adapt to provide the optimal experience.

**Thank you for using SIAKAD! 🎓**

---

*For developers: Check out our [GitHub repository](https://github.com/{repo_name}) for source code and contribution guidelines.*
"""

    return description

def generate_device_compatibility_json():
    """Generate device compatibility matrix"""
    
    compatibility = {
        "version": os.getenv('GITHUB_REF_NAME', 'v1.0.0'),
        "build_date": datetime.utcnow().isoformat() + 'Z',
        "build_number": os.getenv('GITHUB_RUN_NUMBER', '1'),
        "device_profiles": {
            "low": {
                "description": "Optimized for devices with < 2GB RAM",
                "target_devices": "Android 5.0+, ARMv7, < 2GB RAM",
                "features": [
                    "Basic UI with reduced animations",
                    "Low-resolution images by default",
                    "Aggressive memory management",
                    "Simplified transitions"
                ],
                "apk_files": [
                    "app-arm64-v8a-low-release.apk",
                    "app-armeabi-v7a-low-release.apk"
                ],
                "estimated_size": "15-25 MB",
                "performance_score": 25
            },
            "medium": {
                "description": "Optimized for devices with 2-4GB RAM",
                "target_devices": "Android 6.0+, ARMv8, 2-4GB RAM",
                "features": [
                    "Enhanced UI with standard animations",
                    "Medium-resolution images",
                    "Balanced memory management",
                    "Smooth transitions"
                ],
                "apk_files": [
                    "app-arm64-v8a-medium-release.apk",
                    "app-armeabi-v7a-medium-release.apk"
                ],
                "estimated_size": "20-35 MB",
                "performance_score": 50
            },
            "high": {
                "description": "Optimized for devices with 4-8GB RAM",
                "target_devices": "Android 8.0+, ARMv8, 4-8GB RAM",
                "features": [
                    "Full UI with rich animations",
                    "High-resolution images",
                    "Advanced memory management",
                    "Complex transitions and effects"
                ],
                "apk_files": [
                    "app-arm64-v8a-high-release.apk",
                    "app-armeabi-v7a-high-release.apk"
                ],
                "estimated_size": "25-45 MB",
                "performance_score": 75
            },
            "premium": {
                "description": "Optimized for flagship devices with > 8GB RAM",
                "target_devices": "Android 10.0+, ARMv8, > 8GB RAM",
                "features": [
                    "Premium UI with advanced animations",
                    "Ultra-high resolution images",
                    "Maximum quality settings",
                    "4K video support",
                    "Particle effects and advanced transitions"
                ],
                "apk_files": [
                    "app-arm64-v8a-premium-release.apk",
                    "app-armeabi-v7a-premium-release.apk"
                ],
                "estimated_size": "30-60 MB",
                "performance_score": 100
            },
            "universal": {
                "description": "Universal build for all devices with auto-detection",
                "target_devices": "Android 5.0+, All architectures",
                "features": [
                    "Adaptive performance on first launch",
                    "Automatic device detection",
                    "Dynamic asset loading",
                    "All features available based on device capability"
                ],
                "apk_files": [
                    "app-release.apk"
                ],
                "estimated_size": "40-80 MB",
                "performance_score": "adaptive"
            }
        },
        "download_recommendations": {
            "automatic": {
                "method": "smart_download",
                "description": "Use smart download page for automatic device detection",
                "url": f"https://{os.getenv('GITHUB_REPOSITORY', 'your-username/siakad_login').split('/')[0]}.github.io/{os.getenv('GITHUB_REPOSITORY', 'your-username/siakad_login').split('/')[1]}/release/{os.getenv('GITHUB_REF_NAME', 'latest')}/download.html"
            },
            "manual": {
                "method": "manual_selection",
                "description": "Choose specific profile based on device RAM and performance requirements",
                "selection_criteria": {
                    "low": "Devices with < 2GB RAM or older Android versions",
                    "medium": "Devices with 2-4GB RAM, mid-range phones",
                    "high": "Devices with 4-8GB RAM, flagship phones from 2-3 years ago",
                    "premium": "Devices with > 8GB RAM, recent flagship phones",
                    "universal": "Any device when unsure, or for maximum compatibility"
                }
            }
        },
        "technical_specifications": {
            "minimum_android_version": "5.0 (Lollipop)",
            "recommended_android_version": "8.0 (Oreo)",
            "supported_architectures": ["ARM64", "ARMv7"],
            "required_permissions": [
                "INTERNET",
                "WRITE_EXTERNAL_STORAGE",
                "READ_EXTERNAL_STORAGE",
                "CAMERA",
                "VIBRATE"
            ],
            "optional_permissions": [
                "ACCESS_FINE_LOCATION",
                "ACCESS_COARSE_LOCATION",
                "PHONE",
                "SMS"
            ]
        }
    }
    
    return compatibility

if __name__ == "__main__":
    version = os.getenv('GITHUB_REF_NAME', 'v1.0.0').replace('refs/tags/', '')
    build_number = os.getenv('GITHUB_RUN_NUMBER', '1')
    
    # Generate release description
    description = generate_release_description(version, build_number)
    
    # Save to file
    with open('release_description.md', 'w', encoding='utf-8') as f:
        f.write(description)
    
    # Generate device compatibility
    compatibility = generate_device_compatibility_json()
    
    with open('device_compatibility.json', 'w', encoding='utf-8') as f:
        json.dump(compatibility, f, indent=2, ensure_ascii=False)
    
    print("✅ Release description and device compatibility generated successfully!")
    print(f"📄 Release description saved to: release_description.md")
    print(f"📱 Device compatibility saved to: device_compatibility.json")
