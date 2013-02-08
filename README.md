WWW-Naver-SearchAd is a tool for auto bidding at http://searchad.naver.com

1. Make a hashed password via `salogin.js`

    $ node salogin.js `password`    # requires node
    # 99fc288bed... is used as a password for signin

2. use it!

    use WWW:Naver::SearchAd;
    my $ad = WWW:Naver::SearchAd->new;
    die $ad->{error} unless $ad->signin('username', '99fc288bed...');

    my $bundle_id = '11111';

    my $rank      = 11;
    # 1  .. 10 : Power1 .. Power10
    # 11 .. 15 : Biz1 .. Biz5

    die $ad->{error} unless $ad->refresh($bundle_id, $rank);

3. need debugging?

    $ export DEBUG=1    # prints all HTTP Messages to STDOUT
