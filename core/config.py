import json
import os

class ConfigManager:
    def __init__(self, config_path=None):
        if config_path is None:
            # Use user's config directory
            config_home = os.environ.get('XDG_CONFIG_HOME') or os.path.expanduser('~/.config')
            self.config_path = os.path.join(config_home, 'nss-gui', 'config.json')
        else:
            self.config_path = config_path
            
        # Ensure config directory exists
        os.makedirs(os.path.dirname(self.config_path), exist_ok=True)
        
        self.config = self.load_config()
        
    def load_config(self):
        """Load configuration from file"""
        try:
            with open(self.config_path, 'r') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            # Return default configuration
            return {
                "last_ip_range": "",
                "last_selected_ports": [],
                "scan_timeout": 300,
                "theme": "default"
            }
            
    def save_config(self):
        """Save configuration to file"""
        try:
            with open(self.config_path, 'w') as f:
                json.dump(self.config, f, indent=2)
            return True
        except Exception:
            return False
            
    def get(self, key, default=None):
        """Get a configuration value"""
        return self.config.get(key, default)
        
    def set(self, key, value):
        """Set a configuration value"""
        self.config[key] = value
        self.save_config()