SampleProxy - Asynchronous Prototype Proxy
============

## Usage

(Terminal 1) 

```elixir
$ iex -S mix 
Erlang/OTP 20 [RELEASE CANDIDATE 2] [erts-9.0] [source] [64-bit] [smp:2:2] 
[ds:2:2:10] [async-threads:10] [hipe] [kernel-poll:false]

13:35:25.916 module=SampleProxy [info] Starting SampleProxy Application, args: nil 
Interactive Elixir (1.5.1) - press Ctrl+C to exit (type h() ENTER for help) iex(1)>
```

(Terminal 2) 

```elixir
$ ./ngrok http 3738
```

(Terminal 3) 

```elixir
$ jobclient --url "http://3c092ab5.ngrok.io" --account "fozzie@muppets.com"
 50 / 50 [==========================================================] 100.00% 1s

Succeeded: 50
Average Duration: 1.500428507 seconds
Total Duration: 1.616712335 seconds

WORK SAMPLE RESULT: PASSED

Proof :
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
```



## Task Details

Problem

We've deployed a server that you can start jobs on. What do the jobs do? Doesn't 
really matter. What is important is that the jobs will always take ~0.5 seconds 
to complete. You can queue up a job like this:

```elixir
$ curl -H "Content-Type: application/json" -d '{
  "account": "your email address",
  "wait": true
}' http://jobs.asgateway.com/start
```

Since wait is true, the server will just hang until the job is complete, at which 
time it will return this:

```elixir
{
  "id":"4a40f6c1bf585ca9",
  "state":"completed",
  "startedAt":"2015-06-29T15:28:55.497Z",
  "proof":"E850075A4063332DE3D1C254E2A255424361DBDC"
}
```

We've provided a jobclient you can run on your local box against the job server:

```elixir
$ jobclient --account 'example'
50 / 50 [=========================================================] 100.00 % 23s

Succeeded: 50
Average Duration: 11.368634862 seconds
Total Duration: 23.49453871 seconds

WORK SAMPLE RESULT: FAILED
```

Uh oh - the jobclient couldn't complete successfully. What's going on? Well, the 
jobclient runs 50 jobs, and all of those jobs need to both succeed, and they all 
need to complete within 5 seconds. If any jobs return an error, or it takes the 
jobclient more than 5 seconds to run all the jobs, it will fail.

Why can't it complete them in time? Well, it turns out our little job server can 
run a lot of jobs simultaneously. But what it can't do is handle a lot of 
connections simultaneously. Actually, it turns out it can only handle one 
connection at a time per account! All connection attempts after the first one 
will queue up, waiting for the precious single handler.

But the job server provides a way around this - go asynchronous with a callback! 
If you set wait to false, and pass a callback url, the job server will 
immediately return a response:

```elixir
$ curl -H "Content-Type: application/json" -d '{
  "account": "example",
  "wait": false,
  "callback": "http://requestb.in/1573xwm1"
}' http://jobs.asgateway.com/start

Returns:

{
  "state":"running",
  "id":"4499a6e0c2ef4b98"
}

And then, later, it will POST to the callback url you supplied with a 
request like this:

POST http://requestb.in/1573xwm1
Content-Type: application/json
{
  "id":"4499a6e0c2ef4b98",
  "state":"completed",
  "startedAt":"2015-06-29T15:34:16.850Z",
  "proof":"078DC91F2980650231E94E67777078D5C926B9A3"
}
```



This sounds great, so what's the problem? Well, the jobclient which we've 
supplied and that verifies successful completion of the sample, doesn't know 
how to interact with the asynchronous API. It can open up a lot of connections, 
but since it always specifies wait: true, it'll quickly consume the available 
connection and spend all its time waiting for replies.


So your task is simple: write something that sits in-between the supplied client 
and the server, which lets the client hold open a lot of connections, and turns 
the synchronous client requests into asynchronous requests to the server. 

Note that you can pass a url into the jobclient to point it at your 
middleware



