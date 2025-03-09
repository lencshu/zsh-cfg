# 🔧 Custom Zsh Configuration

This repository contains custom **Zsh configurations** for managing development environments, scripts, and tools efficiently.

## 📌 Features

- Modular **Zsh scripts** stored in `~/bin/`
- Optimized **`PATH`** configuration with improved readability and maintenance
- Ensures **no duplicate paths** in `PATH`
- Supports **custom scripts, Python, Flutter, Serverless, and more**

---

## 🚀 Installation & Setup

### **1️⃣ Clone the Repository**

If this repository is not yet cloned, run:

```bash
git clone <your-repo-url> ~/bin
```

### 2️⃣ Add ~/bin to Your Zsh Configuration

Ensure your ~/.zshrc includes the following:

```sh
# Load custom Zsh scripts
for file in ~/bin/*.zsh; do
  [ -r "$file" ] && source "$file"
done
```

Then, reload your Zsh configuration:

```sh
source ~/.zshrc
```

## 📜 Custom Scripts

Your ~/bin/ folder contains various Zsh scripts categorized by functionality:

Script Name Purpose

- z_utils.zsh Utility functions & aliases
- z_git.zsh Git aliases & enhancements
- z_py.zsh Python-related configurations
- z_flutter.zsh Flutter & Dart setup
- z_sls.zsh Serverless framework aliases
- z_node.zsh Node.js & NVM setup
- z_secretive.zsh SSH authentication (Secretive)

Modify or add new scripts as needed.

⸻

## 🔄 Updating Configuration

To apply any changes:

```sh
source ~/.zshrc
```

For a fresh session, restart your terminal.

⸻

## 📌 Troubleshooting

### 1️⃣ command not found for Installed Tools

If tools like atuin or nano show command not found, verify their installation:

```sh
which atuin
which nano
```

If missing, install them using Homebrew:

brew install atuin nano

### 2️⃣ Verify PATH Configuration

Check if the correct paths are loaded:

```sh
echo $PATH
```

Ensure /opt/homebrew/bin or /usr/local/bin is included.

### 3️⃣ Debug Script Loading

If certain scripts fail to load, debug with:

```sh
for file in ~/bin/\*.zsh; do
echo "Loading: $file"
  [ -r "$file" ] && source "$file"
done
```

⸻

## 🎯 Conclusion

This modular Zsh setup improves maintainability, prevents duplication, and ensures correct script execution. Customize it further as needed! 🚀

---

### **Why This README is Effective?**

✔ **Clear structure** – Easy to follow step-by-step installation.  
✔ **Explains why** – Justifies improvements in `PATH` configuration.  
✔ **Provides troubleshooting** – Helps fix common issues.  
✔ **Encourages customization** – Guides users in modifying their own setup.
