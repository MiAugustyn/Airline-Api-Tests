Feature: Test user POST method endpoints

    Background:
        Given url baseUrl
        And path "user"
        # I'm adding highest user ID to created emails to ensure they will be unique each time
        * def getHighestId = call read('Utils.feature@GetHighestUserId')
        * def highestId = getHighestId.highestId 

    @CreateUser
    Scenario: Create new user and call '@GetUserById' with created user ID param
        * def uniqueEmail = 'test' + highestId + '@email.com'
        * def requestBody = {email: '#(uniqueEmail)', name: 'Test', surname: 'User'}
        
        And request requestBody
        When method POST
        Then status 201
        Then match response == "#object"
        Then match response == {id: "#number", email: "#string", name: "#string", surname: "#string"}
        * def getUser = call read('UserGet.feature@GetUserById') {id: '#(response.id)'}
    
    @CreateInvalidUserCalls
    Scenario: Call '@CreateInvalidUser' with invalid email types
        * def getUserEmailUtil = call read('Utils.feature@GetUserEmail')
        * def userEmail = getUserEmailUtil.userEmail
        * def emailExistTest = call read('UserPost.feature@CreateInvalidUser') {email: '#(userEmail)'}
        * def emptyEmailTest = call read('UserPost.feature@CreateInvalidUser') {email: ""}

        # There is no email structure validation, which allows to create invalid email addresses (test is expected to fail)
        * def longString = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" + highestId
        * def LongStringTest = call read('UserPost.feature@CreateInvalidUser') {email: '#(longString)'}
        * def armenianString = "Հայերէն" + highestId
        * def AnotherAlphabetTest1 = call read('UserPost.feature@CreateInvalidUser') {email: '#(armenianString)'}
        * def russianString = "Я люблю писать тесты" + highestId
        * def AnotherAlphabetTest2 = call read('UserPost.feature@CreateInvalidUser') {email: '#(russianString)'}

    @CreateInvalidUser @ignore
    Scenario: Create new user and expect conflict status
        * def requestBody = {email: '#(email)', name: 'Test', surname: 'User'}
        And request requestBody
        When method POST
        Then status 409