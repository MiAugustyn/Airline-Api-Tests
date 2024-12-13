@debug
Feature: Test booking GET method endpoints

    Background:
        Given url baseUrl
        And path "booking"
        * def validParamsUtil = call read('Utils.feature@GetValidBookingParams')
        * def validDate = validParamsUtil.validDate
        * def validUser = validParamsUtil.validUser
        * def nullVar = null

    @GetAllBookingsCalls
    Scenario: Call '@GetAllBookings' with valid params
        # In @GetAllBookings i remove empty params to simulate requests without certain parameters
        * def withoutParamsTest = call read('BookingGet.feature@GetAllBookings') {userId: '', bookingDate: ''}
        * def userOnlyTest = call read('BookingGet.feature@GetAllBookings') {userId: '#(validUser)', bookingDate: ''}
        * def dateOnlyTest = call read('BookingGet.feature@GetAllBookings') {userId: '', bookingDate: '#(validDate)'}
        * def bothParamsTest = call read('BookingGet.feature@GetAllBookings') {userId: '#(validUser)', bookingDate: '#(validDate)'}

    @HandleNullRequests
    Scenario:  Call '@GetAllBookings' with null params (non-null params are valid). API should exclude null params from request.
        * def bothParamsNullTest = call read('BookingGet.feature@GetAllBookings') {userId: '#(nullVar)', bookingDate: '#(nullVar)'}
        * def nullUserTest = call read('BookingGet.feature@GetAllBookings') {userId: '#(nullVar)', bookingDate: '#(validDate)'}
        * def nullDateTest = call read('BookingGet.feature@GetAllBookings') {userId: '#(validUser)', bookingDate: '#(nullVar)'}
        
    
    @InvalidGetAllBookingsCalls
    Scenario: Call '@InvalidGetBookings' with all params invalid
        * def bothParamsEmptyTest = call read('BookingGet.feature@InvalidGetAllBookings') {userId: '', bookingDate: ''}
        * def userZeroDateString = call read('BookingGet.feature@InvalidGetAllBookings') {userId: 0, bookingDate: 'test'}
        * def userStringDateWrongFormat = call read('BookingGet.feature@InvalidGetAllBookings') {userId: 'test', bookingDate: '12-12-2024'}
        
    @InvalidUserGetAllBookingsCalls
    Scenario: Call '@TestInvalidGetBookings' with different invalid user params
        * def userIdZeroTest = call read('BookingGet.feature@InvalidGetAllBooking') {userId: 0, bookingDate: '#(validDate)'}
        * def userIdStringTest = call read('BookingGet.feature@InvalidGetAllBooking') {userId: 'test', bookingDate: '#(validDate)'}
        * def userIdSpacebarTest = call read('BookingGet.feature@InvalidGetAllBooking') {userId: ' ', bookingDate: '#(validDate)'}
        
    @InvalidDateGetAllBookingsCalls
    Scenario: Call '@TestInvalidGetBookings' with different invalid date params
        
        # I assumed that upon specifying a valid user and an invalid type date,
        # a validation error should be returned instead of considering only the correct parameter in the request (test is expected to fail)
        * def dateStringTest = call read('BookingGet.feature@InvalidGetAllBookings') {userId: '#(validUser)', bookingDate: 'test'}
        * def wrongFormatDateTest = call read('BookingGet.feature@InvalidGetAllBookings') {userId: '#(validUser)', bookingDate: '12-12-2024'}
        * def spacebarDateTest = call read('BookingGet.feature@InvalidGetAllBookings') {userId: '#(validUser)', bookingDate: ' '}
        * def numberDateTest = call read('BookingGet.feature@InvalidGetAllBookings') {userId: '#(validUser)', bookingDate: 123}
       
    @GetBookingCall
    Scenario: Call '@GetBooking' with valid ID param
        * def validTest = call read('BookingGet.feature@GetBooking') {id: '#(validUser)'}
    
    @InvalidGetBookingCalls
    Scenario: Call '@InvalidGetBooking' with different invalid ID types
        * def zeroTest = call read('BookingGet.feature@InvalidGetBooking') {id: 0}
        * def textTest = call read('BookingGet.feature@InvalidGetBooking') {id: "text"}
        * def emptyTest = call read('BookingGet.feature@InvalidGetBooking') {id: ''}
        * def nullTest = call read('BookingGet.feature@InvalidGetBooking') {id: #(nullVar)}

    @GetAllBookings @ignore
    Scenario: Gell all bookings and validate response
        * def removeEmptyParamsUtil = call read('Utils.feature@RemoveEmptyParams')
        * def receivedParams = {user: '#(userId)', bookingDate: '#(bookingDate)'}
        * def filledParams = removeEmptyParamsUtil.removeEmptyParams(receivedParams)
        And params filledParams
        And method GET
        Then status 200
        Then match each response == {date: '#string', destination: '#string', id: '#number', origin: '#string', userId: '#number'}

    @InvalidGetAllBookings @ignore        
    Scenario: Get all bookings by invalid params and test error handling 
        * def receivedParams = {user: '#(userId)', bookingDate: '#(bookingDate)'}
        Given params receivedParams
        And method GET
        Then status 400
        Then match response.message == "Validation errors"

    @GetBooking @ignore
    Scenario: GET booking by ID and validate response properties and ID match
        Given path "/" + id
        And method GET
        Then status 200
        Then match response == "#object"
        Then match response == {date: '#string', destination: '#string', id: '#number', origin: '#string', userId: '#number'}
        Then match response.id == id

    @InvalidGetBooking @ignore
    Scenario: GET user by invalid ID and test error handling
        Given path "/" + id
        And method GET
        Then status 400
        Then match response contains {message: "Validation errors"}
