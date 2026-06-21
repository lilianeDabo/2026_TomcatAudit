#!/bin/bash

# If $1 is empty, check common paths natively
if [ -z "$1" ]; then
    if [ -d "/usr/local/tomcat" ]; then
        TOMCAT_HOME="/usr/local/tomcat"
    else
        TOMCAT_HOME="/opt/tomcat"
    fi
else
    TOMCAT_HOME="$1"
fi

SERVER_XML="$TOMCAT_HOME/conf/server.xml"
WEB_XML="$TOMCAT_HOME/conf/web.xml"

echo "=================================================="
echo "      Apache Tomcat Configuration Audit           "
echo "=================================================="

# 1. CHECK: Shutdown port configuration
# Target: port="-1" or non-standard with unguessable string
if [ -f "$SERVER_XML" ]; then
    if grep -q 'port="-1"' "$SERVER_XML"; then
        echo "[CHECK] Shutdown port configuration -> COMPLIANT (Disabled)"
    elif grep -q 'shutdown="SHUTDOWN"' "$SERVER_XML" && grep -q 'port="8005"' "$SERVER_XML"; then
        echo "[CHECK] Shutdown port configuration -> NON-COMPLIANT (Default values)"
    else
        echo "[CHECK] Shutdown port configuration -> PARTIAL (Custom port/command)"
    fi
else
    echo "[CHECK] Shutdown port configuration -> ERROR (server.xml not found)"
fi

# 2. CHECK: Default webapps removed
# Target: docs and examples must be deleted
if [ -d "$TOMCAT_HOME/webapps" ]; then
    if [ -d "$TOMCAT_HOME/webapps/docs" ] || [ -d "$TOMCAT_HOME/webapps/examples" ]; then
        echo "[CHECK] Default webapps removed -> NON-COMPLIANT (docs/examples still present)"
    else
        echo "[CHECK] Default webapps removed -> COMPLIANT"
    fi
else
    echo "[CHECK] Default webapps removed -> ERROR (webapps/ directory not found)"
fi

# 3. CHECK: TLS/HTTPS enabled
# Target: SSLEnabled="true" [Source: Course Material]
if [ -f "$SERVER_XML" ]; then
    # Completely strip multi-line XML comments using awk
    CLEAN_SERVER=$(awk 'BEGIN{RS=""} NR==1{print $0;next} {print $2}' "$SERVER_XML")
    
    if echo "$CLEAN_SERVER" | grep -q 'SSLEnabled="true"'; then
        echo "[CHECK] TLS/HTTPS enabled -> COMPLIANT"
    else
        echo "[CHECK] TLS/HTTPS enabled -> NON-COMPLIANT"
    fi
else
    echo "[CHECK] TLS/HTTPS enabled -> ERROR (server.xml not found)"
fi

# 4. CHECK: Password Hashing / Credential Handler
# Target: MessageDigestCredentialHandler with SHA-256 or SHA-512
if [ -f "$SERVER_XML" ]; then
    # Look for the CredentialHandler line and extract the algorithm
    ALGO=$(grep -oP 'className="org.apache.catalina.realm.MessageDigestCredentialHandler"[^>]*algorithm="\K[^"]+' "$SERVER_XML" 2>/dev/null)
    
    if [ -n "$ALGO" ]; then
        if [ "$ALGO" == "SHA-512" ] || [ "$ALGO" == "SHA-256" ]; then
            echo "[CHECK] User roles secured (Hashing) -> COMPLIANT ($ALGO active)"
        else
            echo "[CHECK] User roles secured (Hashing) -> PARTIAL (Weak algorithm: $ALGO)"
        fi
    else
        echo "[CHECK] User roles secured (Hashing) -> NON-COMPLIANT (Plain-text passwords)"
    fi
else
    echo "[CHECK] User roles secured (Hashing) -> ERROR (server.xml not found)"
fi

# 5. CHECK: Manager Access Restrictions
# Target: RemoteAddrValve or RemoteCIDRValve configured
MANAGER_CONTEXT="$TOMCAT_HOME/webapps/manager/META-INF/context.xml"
if [ -f "$MANAGER_CONTEXT" ]; then
    if grep -q "RemoteAddrValve" "$MANAGER_CONTEXT" || grep -q "RemoteCIDRValve" "$MANAGER_CONTEXT"; then
        # Check if it's the strict default loopback or a custom setup
        if grep -q 'allow="127\\' "$MANAGER_CONTEXT"; then
            echo "[CHECK] Manager network restriction -> COMPLIANT (Localhost only)"
        else
            echo "[CHECK] Manager network restriction -> PARTIAL (Custom IP/CIDR allowed)"
        fi
    else
        echo "[CHECK] Manager network restriction -> NON-COMPLIANT (No IP restrictions)"
    fi
elif [ ! -d "$TOMCAT_HOME/webapps/manager" ]; then
    echo "[CHECK] Manager network restriction -> COMPLIANT (Manager app deleted entirely)"
else
    echo "[CHECK] Manager network restriction -> ERROR (context.xml not found)"
fi

### EXTRA

# 6. CHECK: Version Banner Disclosed (CIS Benchmark 4.1.1 Add-on)
# Target: ErrorReportValve must have showServerInfo="false" and showReport="false"
if [ -f "$SERVER_XML" ]; then
    # Check if ErrorReportValve is defined
    if grep -q "org.apache.catalina.valves.ErrorReportValve" "$SERVER_XML"; then
        # Check if server info and reports are explicitly hidden
        if grep -q 'showServerInfo="false"' "$SERVER_XML" && grep -q 'showReport="false"' "$SERVER_XML"; then
            echo "[CHECK] Version banner hidden -> COMPLIANT (Metadata leakage disabled)"
        else
            echo "[CHECK] Version banner hidden -> PARTIAL (Valve exists but improperly configured)"
        fi
    else
        # Default behavior leaks full version details on error pages
        echo "[CHECK] Version banner hidden -> NON-COMPLIANT (Default error reports leak version info)"
    fi
else
    echo "[CHECK] Version banner hidden -> ERROR (server.xml not found)"
fi

echo "=================================================="