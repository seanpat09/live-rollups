public with sharing class AccountRollupProvider extends DataSource.Provider { 
    /**
     *   Declares the types of authentication that can be used 
     *   to access the external system.
     **/
    override public List<DataSource.AuthenticationCapability> getAuthenticationCapabilities() {
        List<DataSource.AuthenticationCapability> capabilities =
            new List<DataSource.AuthenticationCapability>();
        capabilities.add(
            DataSource.AuthenticationCapability.OAUTH);
        capabilities.add(
            DataSource.AuthenticationCapability.ANONYMOUS);
        return capabilities;
    }
 
    /**
     *   Declares the functional capabilities that the 
     *   external system supports.
     **/
    override public List<DataSource.Capability> getCapabilities() {
        List<DataSource.Capability> capabilities =
            new List<DataSource.Capability>();
        capabilities.add(DataSource.Capability.ROW_QUERY);
        system.debug(capabilities);
        return capabilities;
    }

    /**
     *   Declares the associated DataSource.Connection class.
     **/
    override public DataSource.Connection getConnection(
        DataSource.ConnectionParams connectionParams) {
        system.debug(connectionParams);
        return new AccountRollupConnector(connectionParams);
    }
}