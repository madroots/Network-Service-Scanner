import subprocess
import re
import threading
import ipaddress
from gi.repository import GLib, GObject

class NetworkScanner(GObject.Object):
    __gsignals__ = {
        'scan-complete': (GObject.SignalFlags.RUN_LAST, None, (object,)),
        'scan-progress': (GObject.SignalFlags.RUN_LAST, None, (str,)),
        'scan-error': (GObject.SignalFlags.RUN_LAST, None, (str,))
    }
    
    def __init__(self):
        super().__init__()
        self.scanning = False
        
    def discover_networks(self):
        """Discover available network interfaces and their IP ranges"""
        try:
            # Get network interfaces
            result = subprocess.run(['ip', 'link', 'show'], capture_output=True, text=True, timeout=10)
            interfaces = re.findall(r'\d+: ([^:@]+):', result.stdout)
            
            # Filter out loopback
            interfaces = [iface for iface in interfaces if not iface.startswith('lo')]
            
            # Get IP addresses for each interface
            networks = []
            for interface in interfaces:
                try:
                    result = subprocess.run(['ip', 'address', 'show', interface], 
                                          capture_output=True, text=True, timeout=10)
                    # Extract IP and subnet
                    match = re.search(r'inet ([\d.]+)/(\d+)', result.stdout)
                    if match:
                        ip, prefix = match.groups()
                        network = f"{ip}/{prefix}"
                        networks.append({
                            'interface': interface,
                            'network': network
                        })
                except subprocess.TimeoutExpired:
                    continue
                    
            return networks
        except Exception as e:
            return []
            
    def validate_ip_range(self, ip_range):
        """Validate IP range format"""
        try:
            ipaddress.IPv4Interface(ip_range)
            return True
        except (ipaddress.AddressValueError, ipaddress.NetmaskValueError):
            try:
                ipaddress.IPv4Address(ip_range)
                return True
            except ipaddress.AddressValueError:
                return False
                
    def scan_ports(self, ip_range, ports, callback=None):
        """Scan ports on IP range using nmap"""
        if self.scanning:
            return
            
        self.scanning = True
        
        def run_scan():
            try:
                self.emit('scan-progress', f"Starting scan on {ip_range}")
                
                # Build nmap command
                port_list = ','.join(map(str, ports))
                cmd = ['nmap', '-Pn', '-p', port_list, '-oG', '-', ip_range]
                
                self.emit('scan-progress', f"Executing: {' '.join(cmd)}")
                
                # Run nmap
                result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
                
                if result.returncode != 0:
                    self.emit('scan-error', f"Nmap failed: {result.stderr}")
                    return
                    
                # Parse results
                results = self._parse_nmap_output(result.stdout)
                self.emit('scan-complete', results)
                
            except subprocess.TimeoutExpired:
                self.emit('scan-error', "Scan timed out")
            except Exception as e:
                self.emit('scan-error', f"Scan failed: {str(e)}")
            finally:
                self.scanning = False
                
        # Run in separate thread
        thread = threading.Thread(target=run_scan)
        thread.daemon = True
        thread.start()
        
    def _parse_nmap_output(self, output):
        """Parse nmap grepable output"""
        results = []
        lines = output.strip().split('\n')
        
        for line in lines:
            if line.startswith('#'):  # Comment line
                continue
            if 'Status: Up' not in line:  # Only process hosts that are up
                continue
                
            # Extract IP
            ip_match = re.search(r'Host: ([\d.]+)', line)
            if not ip_match:
                continue
                
            ip = ip_match.group(1)
            
            # Extract ports
            ports_match = re.search(r'Ports: (.+)$', line)
            if not ports_match:
                continue
                
            ports_info = ports_match.group(1)
            # Parse port information (format: port/state/service)
            port_entries = ports_info.split(', ')
            
            for entry in port_entries:
                parts = entry.split('/')
                if len(parts) >= 3:
                    port = int(parts[0])
                    state = parts[1]
                    service = parts[2] if len(parts) > 2 else 'unknown'
                    
                    if state == 'open':
                        results.append({
                            'ip': ip,
                            'port': port,
                            'service': service,
                            'status': 'Open'
                        })
                        
        return results