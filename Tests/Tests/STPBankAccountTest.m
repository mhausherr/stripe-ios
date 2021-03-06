//
//  STPBankAccountTest.m
//  Stripe
//
//  Created by Charles Scalesse on 10/2/14.
//
//

@import XCTest;

#import "STPFormEncoder.h"
#import "STPBankAccount.h"
#import "STPBankAccount+Private.h"

@interface STPBankAccountTest : XCTestCase

@property (nonatomic) STPBankAccount *bankAccount;

@end

@implementation STPBankAccountTest

- (void)setUp {
    [super setUp];
    _bankAccount = [[STPBankAccount alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - STPBankAccountStatus Tests

- (void)testStatusFromString {
    XCTAssertEqual([STPBankAccount statusFromString:@"new"], STPBankAccountStatusNew);
    XCTAssertEqual([STPBankAccount statusFromString:@"NEW"], STPBankAccountStatusNew);

    XCTAssertEqual([STPBankAccount statusFromString:@"validated"], STPBankAccountStatusValidated);
    XCTAssertEqual([STPBankAccount statusFromString:@"VALIDATED"], STPBankAccountStatusValidated);

    XCTAssertEqual([STPBankAccount statusFromString:@"verified"], STPBankAccountStatusVerified);
    XCTAssertEqual([STPBankAccount statusFromString:@"VERIFIED"], STPBankAccountStatusVerified);

    XCTAssertEqual([STPBankAccount statusFromString:@"errored"], STPBankAccountStatusErrored);
    XCTAssertEqual([STPBankAccount statusFromString:@"ERRORED"], STPBankAccountStatusErrored);

    XCTAssertEqual([STPBankAccount statusFromString:@"garbage"], STPBankAccountStatusNew);
    XCTAssertEqual([STPBankAccount statusFromString:@"GARBAGE"], STPBankAccountStatusNew);
}

- (void)testStringFromStatus {
    NSArray<NSNumber *> *values = @[
                                    @(STPBankAccountStatusNew),
                                    @(STPBankAccountStatusValidated),
                                    @(STPBankAccountStatusVerified),
                                    @(STPBankAccountStatusErrored)
                                    ];

    for (NSNumber *statusNumber in values) {
        STPBankAccountStatus status = (STPBankAccountStatus)[statusNumber integerValue];
        NSString *string = [STPBankAccount stringFromStatus:status];

        switch (status) {
            case STPBankAccountStatusNew:
                XCTAssertEqualObjects(string, @"new");
                break;
            case STPBankAccountStatusValidated:
                XCTAssertEqualObjects(string, @"validated");
                break;
            case STPBankAccountStatusVerified:
                XCTAssertEqualObjects(string, @"verified");
                break;
            case STPBankAccountStatusErrored:
                XCTAssertEqualObjects(string, @"errored");
                break;
        }
    }
}

#pragma mark -

- (void)testLast4ReturnsAccountNumberLast4WhenNotSet {
    self.bankAccount.accountNumber = @"000123456789";
    XCTAssertEqualObjects(self.bankAccount.last4, @"6789", @"last4 correctly returns the last 4 digits of the bank account number");
}

- (void)testLast4ReturnsNullWhenNoAccountNumberSet {
    XCTAssertEqualObjects(nil, self.bankAccount.last4, @"last4 returns nil when nothing is set");
}

- (void)testLast4ReturnsNullWhenAccountNumberIsLessThanLength4 {
    self.bankAccount.accountNumber = @"123";
    XCTAssertEqualObjects(nil, self.bankAccount.last4, @"last4 returns nil when number length is < 4");
}

#pragma mark - Equality Tests

- (void)testBankAccountEquals {
    STPBankAccount *bankAccount1 = [STPBankAccount decodedObjectFromAPIResponse:[self completeAttributeDictionary]];
    STPBankAccount *bankAccount2 = [STPBankAccount decodedObjectFromAPIResponse:[self completeAttributeDictionary]];

    XCTAssertEqualObjects(bankAccount1, bankAccount1, @"bank account should equal itself");
    XCTAssertEqualObjects(bankAccount1, bankAccount2, @"bank account with equal data should be equal");
}

#pragma mark - Description Tests

- (void)testDescriptionWorks {
    STPBankAccount *bankAccount = [STPBankAccount decodedObjectFromAPIResponse:[self completeAttributeDictionary]];
    bankAccount.routingNumber = @"123456789";
    XCTAssert(bankAccount.description);
}

#pragma mark - STPAPIResponseDecodable Tests

- (NSDictionary *)completeAttributeDictionary {
    return @{
             @"id": @"something",
             @"last4": @"6789",
             @"bank_name": @"STRIPE TEST BANK",
             @"country": @"US",
             @"fingerprint": @"something",
             @"currency": @"usd",
             @"status": @"new",
             @"account_holder_name": @"John Doe",
             @"account_holder_type": @"company",
             };
}

- (void)testInitializingBankAccountWithAttributeDictionary {
    NSMutableDictionary *apiResponse = [[self completeAttributeDictionary] mutableCopy];
    apiResponse[@"foo"] = @"bar";
    STPBankAccount *bankAccountWithAttributes = [STPBankAccount decodedObjectFromAPIResponse:apiResponse];

    XCTAssertEqualObjects([bankAccountWithAttributes bankAccountId], @"something", @"bankAccountId is set correctly");
    XCTAssertEqualObjects([bankAccountWithAttributes last4], @"6789", @"last4 is set correctly");
    XCTAssertEqualObjects([bankAccountWithAttributes bankName], @"STRIPE TEST BANK", @"bankName is set correctly");
    XCTAssertEqualObjects([bankAccountWithAttributes country], @"US", @"country is set correctly");
    XCTAssertEqualObjects([bankAccountWithAttributes fingerprint], @"something", @"fingerprint is set correctly");
    XCTAssertEqualObjects([bankAccountWithAttributes currency], @"usd", @"currency is set correctly");
    XCTAssertEqual([bankAccountWithAttributes status], STPBankAccountStatusNew);
    XCTAssertEqualObjects([bankAccountWithAttributes accountHolderName], @"John Doe");
    XCTAssertEqual([bankAccountWithAttributes accountHolderType], STPBankAccountHolderTypeCompany);

    NSDictionary *allResponseFields = bankAccountWithAttributes.allResponseFields;
    XCTAssertEqual(allResponseFields[@"foo"], @"bar");
    XCTAssertEqual(allResponseFields[@"last4"], @"6789");
    XCTAssertNil(allResponseFields[@"baz"]);
}

@end
