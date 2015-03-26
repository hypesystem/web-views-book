Introduction
============

**This section should contain:**

- What are the different ways of rendering?
- What is the central tradeoff (the reason for this book's discussions)?

We need some good nomenclature here...

My initial idea was that server-side rendering is called static or dynamic, depending on how it is made (on-request or pre-made-on-server).
Rendering in the browser (ie. including content through javascript) would be called "browser-rendering" because it is different from the others in *where* it is done, rather than *how* (it is always dynamic).

-----

There are three different ways to render a webpage:

1. Prerendering static pages
2. Dynamically rendering pages
3. Pages rendered in the browser

I will briefly detail the use cases and scenarios in which these three ways of rendering are used.
I will also measure the performance of each of them, making recommendations for which are preferrable.

This overview should inform discussions about frameworks and rendering of views.
I believe that the optimum framework will allow for any and all of these ways of rendering.
Most current frameworks allow browser rendering and either prerendering or dynamic rendering, but not both.

I have chosen a simplistic, uninfluenced approach to illustrating the methods of rendering, because this will allow for a reevaluation of current paradigms and frameworks, without assuming that the existing approaches are "correct" or "the best".

Let's start from the bottom up.
First I will show how each kind of rendering is done, and at the end you'll find a section about performance, tradeoffs and my recommendations.
If you find the rendering concepts trivial, feel free to [skip to the last section](#conclusion).

The full code I am referencing can be found in [this gist](https://gist.github.com/hypesystem/be00c5d13b55290ac440).

Pages rendered in the browser
-----------------------------

Let's assume we have some decent data separation, which means that the data we need to access can be found through an API.
This makes browser-rendered pages very easy to build.

Let's start with a basic page showing some information about a user.
The important part is the code where we want dynamically loaded content to appear:

```
<h1>User profile</h1>
<div class="user-info">
  <div>
    <b>Name:</b>
    <span class="name-field">&mdash;</span>
  </div>
  <div>
    <b>Age:</b>
    <span class="age-field">&mdash;</span>
  </div>
  <div>
    <b>Gender:</b>
    <span class="gender-field">&mdash;</span>
  </div>
</div>
```

The file that represents the API (containing any business logic) is called `api.php`. It returns a tiny bit of JSON:

```
{"name":"Wilson","gender":"Ball","age":"13"}
```

In order to display this in the web page, we make a simple Javascript HTTP request to the API, and set the three data fields to the values we receive:

```
<script>
    var nameField = document.querySelector(".name-field");
    var ageField = document.querySelector(".age-field");
    var genderField = document.querySelector(".gender-field");

    var req = new XMLHttpRequest();
    req.open("GET", "api.php");
    req.onreadystatechange = function() {
        var response = JSON.parse(req.responseText);

        nameField.innerHTML = response.name;
        ageField.innerHTML = response.age;
        genderField.innerHTML = response.gender;
    };
    req.send();
</script>
```

The result, which will be mimicked with the other examples, is this:

![Rendered page](https://d23f6h5jpj26xu.cloudfront.net/qzvwg4kcxgndw_small.png)

Dynamically rendering pages
---------------------------

Dynamically rendered pages are all done before they reach the user's browser.
This is achieved through the use of a server-side programming language (often a scripting language like PHP, Ruby or Python).

We can keep most of the page intact:
the general HTML structure is the same, and the presentation HTML changes only slightly.

First, we must retrieve the required data.
This happens before any HTML is rendered.
We use PHP's cURL functions to make a HTTP request to `api.php`:

```
<?php
    // ... (found $rootUrl, to request the correct api.php)
    $curlRequest = curl_init();
    curl_setopt_array($curlRequest, array(
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_URL => "{$rootUrl}/api.php"
    ));
    $result = json_decode(curl_exec($curlRequest));
?>
```

The only other thing we need to replace, is the code of the view itself.
Here, we specify that the values gotten from the API should be printed (using `<?php echo ... ?>`) inside the data fields:

```
<h1>User profile</h1>
<div class="user-info">
  <div>
    <b>Name:</b>
    <span class="name-field">
      <?php echo $result->name; ?>
    </span>
  </div>
  <div>
    <b>Age:</b>
    <span class="age-field">
      <?php echo $result->age; ?>
    </span>
  </div>
  <div>
    <b>Gender:</b>
    <span class="gender-field">
      <?php echo $result->gender; ?>
    </span>
  </div>
</div>
```

The rendered result is exactly the same as in the previous section.

Prerendering static pages
-------------------------

Let's assume that we knew this page would always contain the same information.
The page stops being dynamic, and is instead a static page that can be served to the user without any kind of scripting language (like the PHP and Javascript used in previous examples).

It is really easy to create a static page from a dynamic renderer.
We simply run the PHP interpreter over the page, and output a static html file:

    $ php dynamic-render.php > static-render.htm

Visiting *static-render.htm* now shows the exact same result as the others did.
If the values returned by the API change, however, the static render will not be updated.

Performance and Tradeoffs
-------------------------

What I've shown so far is common knowledge, nothing new:
there are three ways of reaching the same result.
What is interesting is the way in which they differ.

The three ways of rendering perform very differently, in regards of time spent.

The browser-render returns something to the browser very quickly:
after 6 ms, something is shown.
This is, however, the version of the page that contains those `&mdash;`es, rather than the actual content.
The content isn't loaded until around 28 ms in, when the call to `api.php` has concluded.

[![Browser Rendering](https://d23f6h5jpj26xu.cloudfront.net/4oev4arco0lba_small.png)](http://img.svbtle.com/4oev4arco0lba.png)

The dynamic page rendering does all the work on the backend, so it takes much longer to return anything to the screen -- a whopping 13 ms.
On the other hand, once this has happened it is pretty much done, finishing well before the browser rendering.

[![Dynamic Rendering](https://d23f6h5jpj26xu.cloudfront.net/hwaefgdarfyqmq_small.png)](http://img.svbtle.com/hwaefgdarfyqmq.png)

Static rendering, to no one's surprise, is much faster, finishing everything in under 5 ms.
Why?
Because there is no intelligence.
The web server simply returns a HTML page, writing what it reads from the file, without acting in any way.

[![Static Rendering](https://d23f6h5jpj26xu.cloudfront.net/bexewlx7qcizjq_small.png)](http://img.svbtle.com/bexewlx7qcizjq.png)

Performance-wise, static rendering is by far the best.
That means we should encourage this whenever possible.

Rendering time affects more than just a single user's experience:
if every request is slow, refer requests can be handled by the server in a given amount of time.
The faster each rendering is, the better it scales.

Writing pages that are all rendered in the browser is very easy to set up.
Development time is almost non-existant.
Dynamic pages are almost as easy (but they do require some infrastructure, like a web server that can evaluate the language used).
Building a static page that *works* and is still static is a lot harder if any content on the page is ever subject to change.

The web has seen a great many iterations: at first, everything was static, then came the era of dynamically rendering pages, and recently everything has become a web app.

Some people have realized that this isn't necessarily the best direction to go in---at least not for all projects:
web frameworks such as [Jekyll](http://jekyllrb.com/) encourage static pages, generating flat files, which the web server just has to serve.
Jekyll makes it easy to have modern stylesheets and generalized layouts (written once), while still benefitting from the speedy serving of for static pages.

There is a gap in the market, though.
There are no web frameworks that allow for efficiently interspersing statically rendered pages with dynamically rendered ones: either it's Ruby on Rails and every page is processed, or it's Jekyll and every page is static.
(In both cases, it is very possible to have browser-rendering, too -- in fact it is rare to see websites without any kind of in-browser interactivity.)

But think of this:
if you have an article that is read many thousand times per day (without changing), does it really make sense to recompute it before showing it every time?
Of course not.
It would be far more efficient to prerender it, and show the same thing every time.
A rendering will then happen every time a change happens (rarely) rather than every time the page is requested (often).

The problem with serving static pages is evident when considering just how much content is user-based (unique to every visitor):
the username in the header navigation, the personalized comment-box, the targeted content.
None of this can be rendered statically, as it needs to be different for every user visiting.

The easy solution to user-targeted content is rendering it in the browser, but I think a better solution would be to allow for a combination of static and dynamic rendering.

This kind of intelligence is not currently possible (or, at least, supported by any mainstream frameworks), although adding a caching layer on top of the server goes a bit in this direction.
