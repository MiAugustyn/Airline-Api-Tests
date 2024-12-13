@debug
Feature: Test user GET method endpoints

    Background:
        Given url baseUrl
        And path "user"

    @GetAllUsers
    Scenario: GET all users and validate response properties and uniqueness of IDs and emails
        When method GET
        Then status 200
        Then match response == "#array"
        Then match each response == {id: "#number", email: "#string", name: "#string", surname: "#string"}

        * def ids = karate.jsonPath(response, "$..id") 
        * def uniqueIds = karate.distinct(ids)
        Then match ids == uniqueIds

        * def emails = karate.jsonPath(response, "$..email") 
        * def uniqueEmails = karate.distinct(emails)
        Then match emails == uniqueEmails

    @ValidUserIdCall
    Scenario: Call '@GetUserById' with valid ID param
        * def validIdUtil = call read('Utils.feature@GetUserId')
        * def validId = validIdUtil.validId
        * def validTest = call read('UserGet.feature@GetUserById') {id: '#(validId)'}

    @InvalidUserIdCalls
    Scenario: Call '@GetUserByInvalidId' with different invalid ID types
        * def nullVar = null
        * def nullTest = call read('UserGet.feature@GetUserByInvalidId') {id: '#(nullVar)'}
        * def textTest = call read('UserGet.feature@GetUserByInvalidId') {id: "text"}
        * def spaceTest = call read('UserGet.feature@GetUserByInvalidId') {id: ' '}
        * def zeroTest = call read('UserGet.feature@GetUserByInvalidId') {id: 0}

    @GetUserById @ignore
    Scenario: GET user by ID and validate response properties and ID match
        Given path "/" + id
        And method GET
        Then status 200
        Then match response == "#object"
        Then match response == {id: "#number", email: "#string", name: "#string", surname: "#string"}
        Then match response.id == id

    @GetUserByInvalidId @ignore
    Scenario: GET user by invalid ID and test error handling
        Given path "/" + id
        And method GET
        Then status 400
        Then match response contains {message: "Validation errors"}