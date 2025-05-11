from collections import namedtuple
from ipaddress import ip_address
from select import select

P4_PROG = "nips" # replace with the current P4 program

print("Starting setup for {prog}".format(prog=P4_PROG))

exec("p4 = bfrt.{prog}.pipe".format(prog=P4_PROG))  # access to the program-specific table config
port = bfrt.port                                    # port management
pre = bfrt.pre                                      # packet replication engine

### ====================== DIUF-Cluster (machines connected on second network card (enp4s0f1 eth interface)) ====================== ###
# Ports 8 to 15
port_map = [ # port_name | mac | speed
    # Pipeline 1
    ("1/0", "00:00:00:00:00:01", "BF_SPEED_50G"),
    ("1/1", "00:00:00:00:00:02", "BF_SPEED_50G"),
    ("1/2", "00:00:00:00:00:03", "BF_SPEED_50G"),
    ("1/3", "00:00:00:00:00:04", "BF_SPEED_50G"),
    ("1/4", "00:00:00:00:00:05", "BF_SPEED_50G"),
    ("1/5", "00:00:00:00:00:06", "BF_SPEED_50G"),
    ("1/6", "00:00:00:00:00:07", "BF_SPEED_50G"),
    ("1/7", "00:00:00:00:00:08", "BF_SPEED_50G"),
]

SwitchPort = namedtuple("SwitchPort", [ "port_name", "mac", "speed" ])
port_map = list(map(lambda tuple: SwitchPort._make(tuple), port_map))

### ========================================================================================================================================== ###

print("Clearing table entries")

def clear_all(verbose=True, batching=True):
    global p4
    global bfrt
    
    def _clear(table, verbose=False, batching=False):
        if verbose:
            print("Clearing table {:<40} ... ".format(table['full_name']), end='', flush=True)
        try:    
            entries = table['node'].get(regex=True, print_ents=False)
            try:
                if batching: bfrt.batch_begin()

                for entry in entries:
                    entry.remove()
            except Exception as e:
                print("Problem clearing table {}".format(table['name']))
            finally:
                if batching: bfrt.batch_end()
        except Exception as e:
            pass
        finally:
            if verbose: print('Done')

        try: table['node'].reset_default() # reset the default action if there is any
        except: pass

    # The order is important. We do want to clear from the top, table entries use selector groups and selector groups use action profile members    
    for table in p4.info(return_info=True, print_info=False): # Clear Match Tables
        if table['type'] in ['MATCH_DIRECT', 'MATCH_INDIRECT_SELECTOR']:
            _clear(table, verbose=verbose, batching=batching)

    for table in p4.info(return_info=True, print_info=False): # Clear Selectors
        if table['type'] in ['SELECTOR']:
            _clear(table, verbose=verbose, batching=batching)
            
    for table in p4.info(return_info=True, print_info=False): # Clear Action Profiles
        if table['type'] in ['ACTION_PROFILE']:
            _clear(table, verbose=verbose, batching=batching)

clear_all()

### ========================================================================================================================================== ###

### Returns device_port given a port_name under the form "front-port/lane", e.g. "1/0" returns "136" ###
def get_device_port(port_name):
    return port.port_str_info.get(PORT_NAME=port_name, return_ents=True, print_ents=False).data[b'$DEV_PORT'] # port_str_info.get() returns a TableEntry object with .key and .data members

### Returns how many lanes a connection needs given a speed ###
SPEED_TO_LANES = { 'BF_SPEED_50G': 1, 'BF_SPEED_100G': 2, 'BF_SPEED_200G': 4, 'BF_SPEED_400G': 8 }
def get_lanes(speed): 
    return SPEED_TO_LANES[speed]

### Clears a single configuration table ###
def clear_table(table):
    try:
        for entry in table.get(regex=True, print_ents=False): entry.remove()
    except: pass

### ========================================================================================================================================== ###

print("Populating table entries")

# Forward Table
for switch_port in port_map:
    if switch_port.mac == '': continue
    
    p4.SwitchIngress.forward.add_with_hit(dst_addr=switch_port.mac, port=get_device_port(switch_port.port_name))

### ========================================================================================================================================== ###

print("Configuring Tofino 2")

port.port.clear()       # clears all current port configurations
clear_table(pre.mgid)   # clears all current multicast groups
clear_table(pre.node)   # clears all current multicast nodes

print("Configuring ports") # port.port.string_choices() # prints all possible options for port.port.add()

for switch_port in port_map: # Adding and enabling ports
    port.port.add(
        DEV_PORT=get_device_port(switch_port.port_name),
        SPEED=switch_port.speed, N_LANES=get_lanes(switch_port.speed),
        FEC='BF_FEC_TYP_REED_SOLOMON',
        AUTO_NEGOTIATION='PM_AN_FORCE_DISABLE',
        LOOPBACK_MODE="BF_LPBK_NONE",
        PORT_ENABLE=True,
    ) 

### ========================================================================================================================================== ###

bfrt.complete_operations()
