import gi
import threading
import subprocess

gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk, GLib, GObject

from core.scanner import NetworkScanner

class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.set_default_size(800, 600)
        self.set_title("Network Service Scanner")
        
        # Initialize scanner
        self.scanner = NetworkScanner()
        self.scanner.connect('scan-complete', self.on_scan_complete)
        self.scanner.connect('scan-progress', self.on_scan_progress)
        self.scanner.connect('scan-error', self.on_scan_error)
        
        # Create the UI
        self.setup_ui()
        
    def setup_ui(self):
        # Main layout
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=10)
        self.add(main_box)
        
        # Header
        header = Gtk.HeaderBar()
        header.set_show_close_button(True)
        header.props.title = "Network Service Scanner"
        self.set_titlebar(header)
        
        # Toolbar
        toolbar = Gtk.Toolbar()
        main_box.pack_start(toolbar, False, False, 0)
        
        # Network selection
        network_frame = Gtk.Frame(label="Network Selection")
        network_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        network_frame.add(network_box)
        main_box.pack_start(network_frame, False, False, 0)
        
        # Auto-discover button
        self.auto_discover_btn = Gtk.Button(label="Auto Discover Network")
        self.auto_discover_btn.connect("clicked", self.on_auto_discover_clicked)
        network_box.pack_start(self.auto_discover_btn, False, False, 0)
        
        # Manual IP entry
        ip_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=5)
        ip_box.pack_start(Gtk.Label(label="IP Range:"), False, False, 0)
        self.ip_entry = Gtk.Entry()
        self.ip_entry.set_placeholder_text("e.g., 192.168.1.0/24")
        ip_box.pack_start(self.ip_entry, True, True, 0)
        network_box.pack_start(ip_box, False, False, 0)
        
        # Port selection
        port_frame = Gtk.Frame(label="Port Selection")
        port_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=5)
        port_frame.add(port_box)
        main_box.pack_start(port_frame, False, False, 0)
        
        # Common ports grid
        ports_grid = Gtk.Grid()
        ports_grid.set_column_spacing(5)
        ports_grid.set_row_spacing(5)
        
        common_ports = [
            ("SSH (22)", 22), ("HTTP (80)", 80), ("HTTPS (443)", 443),
            ("FTP (21)", 21), ("Telnet (23)", 23), ("VNC (5900)", 5900),
            ("SMTP (25)", 25), ("DNS (53)", 53), ("Custom", 0)
        ]
        
        self.port_buttons = {}
        self.custom_port_entry = None
        
        for i, (label, port) in enumerate(common_ports):
            row = i // 3
            col = i % 3
            
            if port == 0:  # Custom port
                button = Gtk.ToggleButton(label=label)
                self.custom_port_entry = Gtk.Entry()
                self.custom_port_entry.set_placeholder_text("Port number")
                self.custom_port_entry.set_sensitive(False)
                button.connect("toggled", self.on_custom_port_toggled)
                ports_grid.attach(button, col, row, 1, 1)
                ports_grid.attach(self.custom_port_entry, col, row + 1, 1, 1)
                self.port_buttons[port] = (button, self.custom_port_entry)
            else:
                button = Gtk.ToggleButton(label=label)
                ports_grid.attach(button, col, row, 1, 1)
                self.port_buttons[port] = button
                
        port_box.pack_start(ports_grid, False, False, 0)
        
        # Scan button
        self.scan_btn = Gtk.Button(label="Start Scan")
        self.scan_btn.connect("clicked", self.on_scan_clicked)
        self.scan_btn.set_sensitive(False)  # Disabled until network is selected
        port_box.pack_start(self.scan_btn, False, False, 0)
        
        # Results
        results_frame = Gtk.Frame(label="Scan Results")
        results_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        results_frame.add(results_box)
        main_box.pack_start(results_frame, True, True, 0)
        
        # Scrolled window for results
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        results_box.pack_start(scrolled, True, True, 0)
        
        # Results tree view
        self.results_store = Gtk.ListStore(str, int, str, str)  # IP, Port, Service, Status
        self.results_tree = Gtk.TreeView(model=self.results_store)
        
        # Columns
        renderer_ip = Gtk.CellRendererText()
        column_ip = Gtk.TreeViewColumn("IP Address", renderer_ip, text=0)
        self.results_tree.append_column(column_ip)
        
        renderer_port = Gtk.CellRendererText()
        column_port = Gtk.TreeViewColumn("Port", renderer_port, text=1)
        self.results_tree.append_column(column_port)
        
        renderer_service = Gtk.CellRendererText()
        column_service = Gtk.TreeViewColumn("Service", renderer_service, text=2)
        self.results_tree.append_column(column_service)
        
        renderer_status = Gtk.CellRendererText()
        column_status = Gtk.TreeViewColumn("Status", renderer_status, text=3)
        self.results_tree.append_column(column_status)
        
        scrolled.add(self.results_tree)
        
        # Status bar
        self.status_bar = Gtk.Statusbar()
        main_box.pack_start(self.status_bar, False, False, 0)
        
        # Initialize context id for status bar
        self.context_id = self.status_bar.get_context_id("nss")
        
    def on_auto_discover_clicked(self, button):
        self.status_bar.push(self.context_id, "Discovering networks...")
        networks = self.scanner.discover_networks()
        
        if networks:
            # For simplicity, use the first network found
            network = networks[0]['network']
            self.ip_entry.set_text(network)
            self.status_bar.push(self.context_id, f"Found network: {network}")
            self.scan_btn.set_sensitive(True)
        else:
            self.status_bar.push(self.context_id, "No networks found. Please enter IP range manually.")
        
    def on_custom_port_toggled(self, button):
        if self.custom_port_entry:
            self.custom_port_entry.set_sensitive(button.get_active())
            
    def on_scan_clicked(self, button):
        # Get selected ports
        selected_ports = []
        for port, widget in self.port_buttons.items():
            if port == 0:  # Custom port
                button, entry = widget
                if button.get_active() and entry.get_text():
                    try:
                        selected_ports.append(int(entry.get_text()))
                    except ValueError:
                        pass
            else:
                if widget.get_active():
                    selected_ports.append(port)
                    
        if not selected_ports:
            self.status_bar.push(self.context_id, "Please select at least one port to scan")
            return
            
        # Get IP range
        ip_range = self.ip_entry.get_text()
        if not ip_range:
            self.status_bar.push(self.context_id, "Please enter an IP range or use auto-discover")
            return
            
        # Validate IP range
        if not self.scanner.validate_ip_range(ip_range):
            self.status_bar.push(self.context_id, "Invalid IP range format")
            return
            
        self.status_bar.push(self.context_id, f"Scanning {ip_range} on ports: {', '.join(map(str, selected_ports))}...")
        
        # Clear previous results
        self.results_store.clear()
        
        # Disable UI during scan
        self.scan_btn.set_sensitive(False)
        self.scan_btn.set_label("Scanning...")
        self.auto_discover_btn.set_sensitive(False)
        
        # Start scan
        self.scanner.scan_ports(ip_range, selected_ports)
        
    def on_scan_complete(self, scanner, results):
        # Update UI on main thread
        GLib.idle_add(self._update_ui_after_scan, results)
        
    def _update_ui_after_scan(self, results):
        # Add results to store
        for result in results:
            self.results_store.append([
                result['ip'],
                result['port'],
                result['service'],
                result['status']
            ])
            
        # Re-enable UI
        self.scan_btn.set_sensitive(True)
        self.scan_btn.set_label("Start Scan")
        self.auto_discover_btn.set_sensitive(True)
        
        # Update status
        self.status_bar.push(self.context_id, f"Scan complete. Found {len(results)} open ports.")
        
    def on_scan_progress(self, scanner, message):
        # Update status on main thread
        GLib.idle_add(self.status_bar.push, self.context_id, message)
        
    def on_scan_error(self, scanner, error):
        # Update UI on main thread
        GLib.idle_add(self._handle_scan_error, error)
        
    def _handle_scan_error(self, error):
        # Re-enable UI
        self.scan_btn.set_sensitive(True)
        self.scan_btn.set_label("Start Scan")
        self.auto_discover_btn.set_sensitive(True)
        
        # Show error
        self.status_bar.push(self.context_id, f"Scan error: {error}")