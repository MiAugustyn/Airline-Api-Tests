@ignore
Feature: Utility

    Background:
        Given url baseUrl

    @GetUserId
    Scenario: Get existing valid user ID
        Given path "/user"
        When method GET
        Then status 200
        Then match response == "#array"
        Then match each response == {id: "#number", email: "#string", name: "#string", surname: "#string"}
        * def ids = karate.jsonPath(response, "$..id")
        * def validId = ids[0]