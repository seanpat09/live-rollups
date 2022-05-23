public with sharing class AccountRollupConnector extends DataSource.Connection {
    private DataSource.ConnectionParams connectionInfo;
    
    public AccountRollupConnector(
        DataSource.ConnectionParams connectionInfo) {
        this.connectionInfo = connectionInfo;
    }
    
    override public List<DataSource.Table> sync() {
        List<DataSource.Table> tables =
            new List<DataSource.Table>();
        List<DataSource.Column> columns;
        columns = new List<DataSource.Column>();
        columns.add(DataSource.Column.number('DonationTotal', 16, 2));
        columns.add(DataSource.Column.url('DisplayUrl'));
        columns.add(DataSource.Column.text('ExternalId',255));
        columns.add(DataSource.Column.text('Name',255));
        columns.add(DataSource.Column.lookup('AccountRecord','Account'));
        tables.add(DataSource.Table.get('AccountRollup','Name',
            columns));
        return tables;
    }

    override public DataSource.TableResult query(
        DataSource.QueryContext context) {
        DataSource.Filter filter = context.tableSelection.filter;
        system.debug(context);
        List<Map<String, Object>> rows = new List<Map<String, Object>>();
        Set<Id> accountIds = new Set<Id>();
        if (filter != null) {
            if (filter.subfilters != null) {
                for(DataSource.Filter subfilter : filter.subfilters) {
                    if(subfilter.columnName.equals('ExternalId') && subfilter.columnValue != null) {
                        accountIds.add((Id)subfilter.columnValue);
                    }
                }
            }
            if(filter.columnName != null) {
                if(filter.columnName.equals('ExternalId') && filter.columnValue != null) {
                    accountIds.add((Id)filter.columnValue);
                    
                } else if(filter.columnName.equals('DonationTotal') && filter.columnValue != null) {
                    String donationTotal = String.valueOf(filter.columnValue);
                    
                    String query = 'SELECT Account__c, SUM(Amount__c) FROM Donation__c GROUP By Account__c HAVING SUM(Amount__c)' + getComparativeSymbol(filter.type) + ' ' + donationTotal;
                    System.debug(query);
                    rows = buildRows(Database.query(query));
                }
            }

            if(!accountIds.isEmpty()) {
                rows = buildRows([
                    SELECT Account__c, SUM(Amount__c)
                    FROM Donation__c
                    WHERE Account__c = :accountIds
                    GROUP BY Account__c
                ]);
            }
        } else {
            rows = buildRows([
                SELECT Account__c, SUM(Amount__c)
                FROM Donation__c GROUP BY Account__c
            ]);
        }
        return DataSource.TableResult.get(true, null, context.tableSelection.tableSelected, rows);
    }

    private List<Map<String, Object>> buildRows(List<AggregateResult> results) {
        Map<Id,Map<String, Object>> rowByAccountId = new Map<Id,Map<String, Object>>();
        for(AggregateResult ar : results) {
            rowByAccountId.put(
                (Id)ar.get('Account__c'),
                new Map<String,Object>{
                    'ExternalId' => ar.get('Account__c'),
                    'AccountRecord' => (Id)ar.get('Account__c'),
                    'DonationTotal' => ar.get('expr0')
                }
            );
        }
        for(Account a : [SELECT Id, Name FROM Account WHERE ID IN :rowByAccountId.keySet()]) {
            rowByAccountId.get(a.Id).put('Name', a.Name);
        }
        return rowByAccountId.values();
        
    }

    private String getComparativeSymbol(DataSource.FilterType filterType) {
        if( filterType == Datasource.FilterType.EQUALS) {
            return '=';
        }	
        else if( filterType == Datasource.FilterType.GREATER_THAN_OR_EQUAL_TO) {
            return '>=';
        }
        else if( filterType == Datasource.FilterType.GREATER_THAN) {
            return '>';
        }
        else if( filterType == Datasource.FilterType.LESS_THAN_OR_EQUAL_TO) {
            return '<=';
        }
        else if( filterType == Datasource.FilterType.LESS_THAN) {
            return '<';
        }
        else if( filterType == Datasource.FilterType.NOT_EQUALS) {
            return '!=';
        }
        return '=';
    }
}