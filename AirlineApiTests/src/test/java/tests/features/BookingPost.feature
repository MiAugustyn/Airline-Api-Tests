Feature:

    Background:
        Given url baseUrl
        And path "booking"
        * def validParamsUtil = call read('Utils.feature@GetValidBookingParams')
        * def validDate = validParamsUtil.validDate
        * def validUser = validParamsUtil.validUser
        * def validDestination = validParamsUtil.validDestination
        * def validOrigin = validParamsUtil.validOrigin
        * def nullVar = null

    @CreateBooking
    Scenario: Create booking and call '@GetBooking' with created booking ID param
        * def requestBody = {date: '#(validDate)', destination: '#(validDestination)', origin: '#(validOrigin)', userId: '#(validUser)'}
        Given request requestBody
        When method POST
        Then status 201
        Then match response == {date: '#string', destination: '#string', id: '#number', origin: '#string', userId: '#number'}
        * def getUser = call read('BookingGet.feature@GetBooking') {id: '#(response.id)'}
        Then match response.id == getUser.response.id

    @CreateIdenticalBookings
    Scenario: Create two bookings with same params (by calling '@CreateBooking' twice)
        * def createValidUserTest1 = call read('BookingPost.feature@CreateBooking')
        * def createValidUserTest2 = call read('BookingPost.feature@CreateBooking')
        Then match createValidUserTest1.response.id != createValidUserTest2.response.id

    @InvalidParamsTest
    Scenario: Call '@CreateInvalidBooking' with invalid params
        * def nullParamsTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(nullVar)', destination: '#(nullVar)', origin: '#(nullVar)', userId: '#(nullVar)'}
        * def emptyParamsTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '', destination: '', origin: '', userId: ''}

    @InvalidDateTest
    Scenario: Call '@CreateInvalidBooking' with invalid date param
        * def wrongDateFormatTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '12-12-2024', destination: '#(validDestination)', origin: '#(validOrigin)', userId: '#(validUser)'}
        * def stringDateTest = call read('BookingPost.feature@CreateInvalidBooking') {date: 'test', destination: '#(validDestination)', origin: '#(validOrigin)', userId: '#(validUser)'}
        * def FiveDigitsYearTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '12345-09-15', destination: '#(validDestination)', origin: '#(validOrigin)', userId: '#(validUser)'}
        * def NullDateTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(nullVar)', destination: '#(validDestination)', origin: '#(validOrigin)', userId: '#(validUser)'}

    @InvalidDestinationTest
    Scenario: Call '@CreateInvalidBooking' with invalid destination param
        * def destinationTooShortTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: 'A', origin: '#(validOrigin)', userId: '#(validUser)'}
        * def destinationTooLongTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: 'ABCD', origin: '#(validOrigin)', userId: '#(validUser)'}
        * def intDestinationTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: 123, origin: '#(validOrigin)', userId: '#(validUser)'}
        * def AnotherAlphabetDestinationTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: 'что', origin: '#(validOrigin)', userId: '#(validUser)'}
        * def nullDestinationTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(nullVar)', origin: '#(validOrigin)', userId: '#(validUser)'}

    @InvalidOriginTest
    Scenario: Call '@CreateInvalidBooking' with invalid origin param
        * def originTooShortTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: 'D', userId: '#(validUser)'}
        * def originTooLongTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: 'DEFG', userId: '#(validUser)'}
        * def intOriginTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: '123', userId: '#(validUser)'}
        * def AnotherAlphabetOriginTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: 'что', userId: '#(validUser)'}
        * def nullOriginTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: '#(nullVar)', userId: '#(validUser)'}

    @InvalidUserTest
    Scenario: Call '@CreateInvalidBooking' with invalid user param
        * def zeroUserTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: '#(validOrigin)', userId: 0}
        * def highestIdUtil = call read('Utils.feature@GetHighestUserId')
        * def invalidUser = highestIdUtil.highestId + 100
        * def tooHighUserTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: '#(validOrigin)', userId: '#(invalidUser)'}
        * def stringUserTest = call read('BookingPost.feature@CreateInvalidBooking') {date: '#(validDate)', destination: '#(validDestination)', origin: '#(validOrigin)', userId: 'test'}

    @CreateInvalidBooking @ignore
    Scenario: Create invalid user and expect validation error
        * def requestBody = {date: '#(date)', destination: '#(destination)', origin: '#(origin)', userId: '#(userId)'}
        Given request requestBody
        When method POST
        Then assert responseStatus == 400 || responseStatus == 404
        Then match response contains {message: "#notnull"}
