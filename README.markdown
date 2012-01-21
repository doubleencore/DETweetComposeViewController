DETweetComposeViewController
============================

DETweetComposeViewController uses git submodules to pull in the [unoffical-twitter-sdk](https://github.com/doubleencore/unoffical-twitter-sdk). Be sure to run 
```git submodule update --init``` on your DETweetComposeViewController  clone before proceeding.

## What is it?
DETweetComposeViewController is an iOS 4 compatible version of the TWTweetComposeView controller. Otherwise known as the Tweet Sheet.

## Why did we make it?
The iOS 5 TWTweetComposeViewController makes it really simple to integrate Twitter posting into you applications. However we still need to support iOS 4 in many of our applications. Having something that looks and acts like the built in Tweet Sheet allows us to have a consistent user interface across iOS versions.

## What does it look like?
![DETweetComposeViewController](https://github.com/downloads/doubleencore/DETweetComposeViewController/DETweetComposeViewController.png) ![TWTweetComposeViewController](https://github.com/downloads/doubleencore/DETweetComposeViewController/TWTweetComposeViewController.png)

As you can see they look very similar.  
  
## How do you use it?

1. Add all the files from the DETweetComposeViewController/DETweetComposeViewController folder to your project.
2. From DETweetComposeViewController/DETweeter/unofficial-twitter-sdk/unoffical-twitter-sdk, add the following to a group in your project named unoffical-twitter-sdk:
    1. JSON/
    2. OAuth/
    3. tclose.png
    4. ticon.png
    5. TwitterDialog.h
    6. TwitterDialog.m
3. Link your project against the follwoing frameworks:
    1. Accounts.framework
    2. Twitter.framework.
4. Set your Twitter OAuth Consumer Key and Consumer Secret in OAuthConsumerCredentials.h in your project, you will find this file in unoffical-twitter-sdk/OAuth. Don't have an OAuth consumer key and secret? Go to developer.twitter.com to create an app. Make sure your app's Access is set to 'Read and Write' and a Callback URL is defined. Both of these configurations can be found under the Settings of your Twitter app.
5. You will notice there is an #error in OAuthConsumerCredentials.h to help ensure you remember to add your Twitter OAuth credentials, remember to delete this #error after you have added your OAuth credentials.
6. Use it almost just like you would a TWTweetComposeViewController

```
#import "DETweetComposeViewController.h"
...
DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
[tcvc addImage:[UIImage imageNamed:@"YawkeyBusinessDog.jpg"]];
[tcvc addURL:[NSURL URLWithString:@"http://www.DoubleEncore.com/"]];
[tcvc addURL:[NSURL URLWithString:@"http://www.apple.com/ios/features.html#twitter"]];
self.modalPresentationStyle = UIModalPresentationCurrentContext;
[self presentModalViewController:tcvc animated:YES];
```

## What if I don't want to use the unofficial-twitter-sdk?

Just save the necessary OAuth credentils to NSUserDefaults as:

 * detwitter_oauth_token
 * detwitter_oauth_token_secret
 * detwitter_oauth_token_authorized

Then call the OAuth ```- (void) loadOAuthContextFromUserDefaults;``` method.

## What's next?

We have some TODO items in [github Issues](https://github.com/doubleencore/DETweetComposeViewController/issues). Please send us your feature requests, patches and pull requests.

## Credits

1. unofficial-twitter-sdk [lloydsparkes](https://github.com/lloydsparkes)
2. InnerShadowDrawing [mruegenberg](https://github.com/mruegenberg/objc-utils/tree/master/UIKitAdditions)
