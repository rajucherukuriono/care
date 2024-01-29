/****************************************************************************
Created By: Alan Oshry
Email: alan.oshry@revelanttech.com
Created: 09/14/2020
Description: Unit Test class for AutocompleteController
Comments:
*****************************************************************************/
@isTest
private class AutocompleteController_Test {

    @isTest static void testAutocomplete() {
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Excellent Software Inc'));
        accounts.add(new Account(Name = 'Artist Loft'));
        accounts.add(new Account(Name = 'Microsoft'));
        accounts.add(new Account(Name = 'Apple Inc'));
        insert accounts;

        List<Account> accountsResult = AutocompleteController.fetchLookUpValues('oft', 'Account', 'Name');
        System.assertEquals(3, accountsResult.size());

        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'Joe', LastName = 'Smith'));
        contacts.add(new Contact(FirstName = 'Amy', LastName = 'Johnson'));
        contacts.add(new Contact(FirstName = 'Barry', LastName = 'Manilow'));
        contacts.add(new Contact(FirstName = 'Gag', LastName = 'Halfrunt'));
        insert contacts;

        List<Contact> contactsResult = AutocompleteController.fetchLookUpValues('half', 'Contact', 'LastName');
        System.assertEquals(1, contactsResult.size());
    }
}