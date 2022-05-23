Account a = new Account(Name = 'Big Donor');

Account b = new Account(Name = 'Small Donor');
insert new List<Account>{a, b};


insert new List<Donation__c> {
	new Donation__c(Amount__c = 1000, Account__c = a.Id),
    new Donation__c(Amount__c = 2000, Account__c = a.Id),
	new Donation__c(Amount__c = 10, Account__c = b.Id),
    new Donation__c(Amount__c = 20, Account__c = b.Id)
};

System.debug([SELECT Name__c, DonationTotal__c FROM AccountRollup__x]);/*  */