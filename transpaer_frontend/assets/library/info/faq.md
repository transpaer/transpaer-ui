# How can I help?

There are many ways you can help:

First, if you found some bug or problem with our data or you have an idea for a new feature, let us know on [our Discord server](https://discord.com/invite/G7Vu2SeW).

Secondly, if you are a programmer you can help directly by contrubuting to [our code](https://github.com/transpaer/). All our software is open-source.

And lastly, if you don't have time to contribute directly, we will soon open some donation channels, so you can help us pay for the infrastructure and maybe even enable us to work on this project full-time.

# Do you use or plan to use AI?

No. Not yet.

TLDR: AI is good at art, but bad at science.

When you develop an AI you give it example inputs and outputs you expect it to give.
Then, after process of training your AI on these data, it is expected to be able to give
approximate answers to the inputs it didn't see before.
In essence it means that AI guesses the answers.
This makes it a perfect tool to tackle problems like image or speech recognition,
text translation or chat bots, where input and/or output space is big and answer can be formulated
in many ways that are appoximately correct,
but does not work well in our case when even data needed to train the AI does not exist yet.

Another problem is that while AI gives some answers,
it is hard to tell how it came up with it, which is crucial in our case.
If some product is promoted or demoted, we have to know exactly why
(e.g. because it was reported that the producer released chemicals to a river),
not because some neural network happend to return such answer.
XIA (Explainable IA) is a field of active research.

That said, we may use AI for some supportive tasks and data analysis,
and maybe use it in the future in the main algorithm if we build data set big enough
to train an AI on it and reliable XAI methods are developed. 

# What are your costs to run this service/app?

We don't hire anyone. All you can see here is a volunteer work,
so all our costs is what we pay for servers to run this service on.

Currently we have the smallest possible non-scalable deployment in one data center in Europe.
This means that
 - for everyone outside of Europe the website works slowly
 - the website is down when we release a new version
 - in case we experience higher traffic, the website will likely go down.

We pay for this deployment around 100 euro per month.
 
