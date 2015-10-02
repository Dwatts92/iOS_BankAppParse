//
//  BankViewController.m
//  Assignment 3 (Assignment1.prac)
//
//  Created by Dylan Watts on 9/8/14.
//  Copyright (c) 2014 Dylan Watts. All rights reserved.
//
//  The bank controller lets user see the current balance, fields to input deposit and withdrawal numbers, and lets them go to the
//  transactions view.

#import "BankViewController.h"                  //importing the controllers and model headers for use.
#import "TransactionsViewController.h"
#import "BankAccount.h"
#import "BalanceModel.h"





@interface BankViewController ()

@property (weak, nonatomic) IBOutlet UILabel *warningDisplay;   //warning signs to user

@property (weak, nonatomic) IBOutlet UILabel *balance;          //current Balance number gets updated by BankAccount instantly upon transaction

@property (weak, nonatomic) IBOutlet UITextField *deposit;      //dep and withd fields
@property (weak, nonatomic) IBOutlet UITextField *withdraw;
@property (weak, nonatomic) IBOutlet UILabel *currTest;

- (IBAction)depOK:(id)sender;       //OK buttons
- (IBAction)withOK:(id)sender;

- (IBAction)usd:(id)sender;
- (IBAction)eur:(id)sender;
- (IBAction)cad:(id)sender;
- (IBAction)jpy:(id)sender;
- (IBAction)aud:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *currRate;



@property NSMutableArray *objects; //array filled with transaction/bank objects

@property double initBal;          //initial balance number

@property NSNumber *balNumber;      //for putting balance into Parse

@property BalanceModel *counter;    //Balance model has a couple 

@property NSString* thistransaction;    //string holds one transaction, specifically to output NSLog

@end


@implementation BankViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currency = @"USD";
    
    
    self.warningDisplay.text = @"";     //intializes warning label to be blank
    
    [self loadItems];                   //loads data into objects array
    
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
        
    }
    
    
    self.initBal = ((BankAccount*)[self.objects firstObject]).bankBalance;        //gets intial balance from the first object on the array.
    
    self.balNumber = [NSNumber numberWithFloat: self.initBal];
    
    /*PFObject *parseBal = [PFObject objectWithClassName:@"Balance"];                 //save balance to Parse
    parseBal[@"value"] = self.balNumber;
    [parseBal saveInBackground];*/
    
    NSString* totalBalance = [NSString stringWithFormat:@"%.02f", self.initBal];    //gets balance from BankAccount object that keeps up to date
    
    PFObject *parseBal = [PFObject objectWithClassName:@"Balance"];                 //save balance to Parse
    parseBal[@"value"] = totalBalance;
    [parseBal saveInBackground];
    
    self.balance.text=totalBalance;                                                 //and displays it up top
    
    NSLog(@"Balance: %g",self.initBal);           //shows initial balance in NSlog
    
    
    self.counter = [[BalanceModel alloc] initWithBal:self.initBal initWithValid:true];      //sends balance to other model for calculations
    self.thistransaction =@"";                                                              //initialize transactions, used for displaying transaction

}                                                                                           //in NsLog



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event   //this method minimizes the keypad if touched outside of the keypad in a non-functional area.
{
    [self.deposit resignFirstResponder];
    [self.withdraw resignFirstResponder];
}



- (IBAction)depOK:(id)sender {          //method for hitting okay button by deposit.
    
    self.warningDisplay.text = @"";
    
    self.balance.text = [self.counter incrementBal:self.deposit.text.floatValue]; //BalanceModel runs incrementing calcs, prints its balance value to the label
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];                 //these methods get the current date and time of click and put them in a string
    [formatter setDateFormat:@"MM/dd/yy hh:mm:ss"];
    self.currentDate = [formatter stringFromDate:[NSDate date]];
    
    if (self.counter.valid == true)                             //checks if there was a negative number desposited
    {
        if (!self.objects) {                                    //if there wasn't store all data in BankAccount with Deposit transaction type
            self.objects = [[NSMutableArray alloc] init];
        }
        BankAccount *account = [[BankAccount alloc] init];
        account.theDate = self.currentDate;
        account.transAmount = self.deposit.text.floatValue;
        account.transType = @"Deposit";
        account.bankBalance =self.balance.text.floatValue;
        
        PFObject *parseBal = [PFObject objectWithClassName:@"Balance"];                 //save balance to Parse
        parseBal[@"value"] = self.balance.text;
        [parseBal saveInBackground];
        
        PFObject *transaction = [PFObject objectWithClassName:@"Transactions"];                 //save values to Parse
        transaction[@"date"] = self.currentDate;
        transaction[@"transAmount"] = self.deposit.text;
        transaction[@"transType"] = @"Deposit";
        
        [transaction saveInBackground];
        
        
        [self.objects insertObject:account atIndex:0];          //sticks the data/transaction on top
        
        self.thistransaction = [[[[@"\nDeposit: $ " stringByAppendingString:self.deposit.text]stringByAppendingString:@"  "]stringByAppendingString: self.currentDate]stringByAppendingString:@"\n"];
        NSLog(@"%@", self.thistransaction);                     //this appends everything into a single transaction string for NSLog
    
    [self.deposit resignFirstResponder];                        //closes keypad if ok is hit.
        
    }
    else
    {
        if (!self.objects) {                                    //same thing as above, only stores the transaction in BankAccount with Invalid Deposit.
            self.objects = [[NSMutableArray alloc] init];       //BalanceModel takes care of the if/else statement and error checking here.
        }
        BankAccount *account = [[BankAccount alloc] init];      //storing date & time, transactionamount, type, and balance
        account.theDate = self.currentDate;
        account.transAmount = self.deposit.text.floatValue;
        account.transType = @"Invalid Deposit";
        account.bankBalance =self.balance.text.floatValue;
        
        PFObject *parseBal = [PFObject objectWithClassName:@"Balance"];                 //save balance to Parse
        parseBal[@"value"] = self.balance.text;
        [parseBal saveInBackground];
        
        PFObject *transaction = [PFObject objectWithClassName:@"Transactions"];                 //save values to Parse
        transaction[@"date"] = self.currentDate;
        transaction[@"transAmount"] = self.deposit.text;
        transaction[@"transType"] = @"Invalid Deposit";
        
        [transaction saveInBackground];
        
        [self.objects insertObject:account atIndex:0];
        
        self.warningDisplay.text = @"Bad transaction. Trying to deposit negative number. Try again.";   //warning for negative deposit, can't over deposit.
        [self.deposit resignFirstResponder];
    }
    
    [self saveItems];   //save BankAccount objects to file.
    
}

- (IBAction)withOK:(id)sender {     //method for hitting okay button by withdraw, it functions the same as above except takes money away from balance.
    
    self.warningDisplay.text = @"";
    
    self.balance.text = [self.counter decrementBal:self.withdraw.text.floatValue];  //BalanceModel runs decrementing calculation, returns balance.
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];                    //these methods get the current date and time and put them in a string
    [formatter setDateFormat:@"MM/dd/yy hh:mm:ss"];
    self.currentDate = [formatter stringFromDate:[NSDate date]];
    
    if (self.counter.valid == true) //checks if there was a negative number desposited
    {
        
        if (!self.objects) {
            self.objects = [[NSMutableArray alloc] init];       //same as deposit comments above
        }
        

        BankAccount *account = [[BankAccount alloc] init];
        account.theDate = self.currentDate;
        account.transAmount = self.withdraw.text.floatValue;
        account.transType = @"Withdraw";
        account.bankBalance =self.balance.text.floatValue;
        
        PFObject *parseBal = [PFObject objectWithClassName:@"Balance"];                 //save balance to Parse
        parseBal[@"value"] = self.balance.text;
        [parseBal saveInBackground];
        
        PFObject *transaction = [PFObject objectWithClassName:@"Transactions"];                 //save values to Parse
        transaction[@"date"] = self.currentDate;
        transaction[@"transAmount"] = self.withdraw.text;
        transaction[@"transType"] = @"Withdraw";
        
        [transaction saveInBackground];
        
        [self.objects insertObject:account atIndex:0];
    
    self.thistransaction = [[[[@"\nWithdraw: $ " stringByAppendingString:self.withdraw.text]stringByAppendingString:@"  "]stringByAppendingString: self.currentDate]stringByAppendingString:@"\n"];
    NSLog(@"%@", self.thistransaction);
    
    
    [self.withdraw resignFirstResponder];
        
    }
    else
    {
        if (!self.objects) {
            self.objects = [[NSMutableArray alloc] init];
        }
        
        
        BankAccount *account = [[BankAccount alloc] init];
        account.theDate = self.currentDate;
        account.transAmount = self.withdraw.text.floatValue;
        account.transType = @"Invalid Withdraw";
        account.bankBalance =self.balance.text.floatValue;
        
        PFObject *parseBal = [PFObject objectWithClassName:@"Balance"];                 //save balance to Parse
        parseBal[@"value"] = self.balance.text;
        [parseBal saveInBackground];
        
        PFObject *transaction = [PFObject objectWithClassName:@"Transactions"];                 //save values to Parse
        transaction[@"date"] = self.currentDate;
        transaction[@"transAmount"] = self.withdraw.text;
        transaction[@"transType"] = @"Invalid Withdraw";
        
        [transaction saveInBackground];
        
        [self.objects insertObject:account atIndex:0];
        
        self.warningDisplay.text = @"Bad transaction. You're trying to withdraw more than you have or enter negative numbers. Try again.";
        [self.withdraw resignFirstResponder];
    }
    
    [self saveItems];
}

- (IBAction)usd:(id)sender {
    
    self.balance.text=[self conversion:self.currency second:@"USD" third:self.balance.text];
    self.currency = @"USD";
    self.currRate.text = @"USD";
    
}

- (IBAction)eur:(id)sender {
    
    self.balance.text=[self conversion:self.currency second:@"EUR" third:self.balance.text];
    self.currency = @"EUR";
    self.currRate.text = @"EUR";
}

- (IBAction)cad:(id)sender {
    
    self.balance.text=[self conversion:self.currency second:@"CAD" third:self.balance.text];
    self.currency = @"CAD";
    self.currRate.text = @"CAD";
}

- (IBAction)jpy:(id)sender {
    
    self.balance.text=[self conversion:self.currency second:@"JPY" third:self.balance.text];
    self.currency = @"JPY";
    self.currRate.text = @"JPY";
}

- (IBAction)aud:(id)sender {
    
    self.balance.text=[self conversion:self.currency second:@"AUD" third:self.balance.text];
    self.currency = @"AUD";
    self.currRate.text = @"AUD";
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender    //method transfers the data, aka the transactions over to our transaction view
 {
 TransactionsViewController *dest = segue.destinationViewController;

     dest.transactions = self.objects;

 }


- (NSString *)documentsDirectory
{

    return [@"~/Documents" stringByExpandingTildeInPath];
}
- (NSString *)dataFilePath
{
    //COMMENT IN FOR DIRECTORY VIEW
    
    //NSLog(@"%@",[self documentsDirectory]);
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Itemlist.plist"];
    
}

-(NSString*)conversion:(NSString *)nfirst second:(NSString*)nsecond third:(NSString*)nthird

  /* self.thistransaction = [[[[@"\nWithdraw: $ " stringByAppendingString:self.withdraw.text]stringByAppendingString:@"  "]stringByAppendingString: self.currentDate]stringByAppendingString:@"\n"];*/
{
    NSString * result = [[[[[[@"http://www.exchangerate-api.com/" stringByAppendingString:nfirst]stringByAppendingString:@"/"]stringByAppendingString:nsecond]stringByAppendingString:@"/"]stringByAppendingString:nthird]stringByAppendingString:@"?k=pWCeB-n2DFh-4yerB"];
    
    return[NSString stringWithContentsOfURL:[NSURL URLWithString:result]encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)error:NULL];
    
}

- (void)saveItems
{
    
    // create a generic data storage object
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:self.objects forKey:@"Items"];   //saves our objects to file.
    
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
    
}

- (void)loadItems
{
    // get our data file path
    NSString *path = [self dataFilePath];
    
    //do we have anything in our documents directory?  If we have anything then load it up
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.objects = [unarchiver decodeObjectForKey:@"Items"];
        [unarchiver finishDecoding];
    }
}

@end
