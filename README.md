


## NIAS3
Welcome to the nias3 main repo.

NIAS3 is a lightweight infrastructure to make working with the many forms of data encountered in the education world easier to manage.

This repository is the umbrella project that pulls together the binary releases and documentation for the nias3 product.

There's very little code here other than build scripts and release tools, if you download this repo you can run the main build.sh to create your own versions of nias3, but the code will be pulled in from a number of supporting repositories that provide the components of nias3, more details below the quick-start.

Beyond the quickstart here more details of the system components, how to get data in and out of n3, and system requirements can be found in this site's wiki [here](https://github.com/nsip/n3/wiki). 

## Quick Start
Download one of our pre-built binary packages [here](https://github.com/nsip/n3/releases)
and unzip the archive on your computer.

Navigate in a terminal or command prompt to the download folder, and launch the applications in the following order (you can run these in the background or in separate processes as you prefer):

*Windows:*
> start ./nats-streaming-server

*Linux:*
> ./nats-streaming-server

nias3 needs a NATS server to be running.

*Windows:*
> start ./n3w

*Linux:*
> ./n3w 

This launches the main nias3 application which handles publishing of data, distribution of data and querying of data.
The n3w application bundled here also hosts a number of demo applications you can use in your browser.

finally run:

*Windows:*
> start ./load

*Linux:*
> ./load

to populate your new nias3 instance with some sample education data. This little tool simply creates a known demo user on the system and then publishes a set of mixed education data relating to a demonstration school; SIF data, xAPI data and various arbitrary JSON data formats for things like syllabuses and lessons, to replicate the typical mix that education environments have to cope with.

optionally you can run 

*Windows:*
> start ./dc-curriculum-service

*Linux:*
> ./dc-curriculum-service

which provides another source of meta-data feeding into the system which can be used in a couple of the demos.

nias3 tries to make working with multiple education data sources easier.
You can publish any json data to it.
It will dynamically build a GraphQL schema from the data it sees, and this enables you to make queries across all of the data in the datastore in a single consistent way.
More importantly nias3 has its own lightweight graph datastore which will also (according to configuration rules), automatically create links between different datasets in different formats.
Traversal-type queries can be created that move across the different datasets but link the relevant resources together.

You will find demos of these concepts are being served at the following locations by your n3w instance:

## Included Demos
## multi-model 1
demo url:
> http://localhost:1323/mm1/

very simple hard-coded display of a traversal in action.
Moves from a known entity of a teacher in a SIF record; through other linked SIF records to find teaching-groups and therefore students; to the xAPI records for an individual student who took assessments related to the subject the teaching group is for; to an arbitrary json record produced at a school level that defines the subject taught; to the syllabus that was in place for that subject when it was taught, to the lessons (again arbitrary json format) that were taught.

The web ui simply runs the query, and then shows the content of all of the objects it was able to find following the traversal.

## digital-classroom lesson planner 

demo url:
> http://localhost:8002

(Digital Classroom is the project sponsored by the NSW Department of Education that allowed us to undertake this development work)

The Lesson-Planner allows you create a schedule of lessons based on the syllabus data sent into nias3 by the load process.

(Note only HSIE History & Geography syllabuses are bundled in the distribution. )

The significance of this demo is to show firstly how useful machine-readable reference data can be in helping to create systems that help teachers, secondly that you can get lots of value from even an arbitrary encoding of the syllabus (like ours is here) if you have some tools that will link it successfully to other data in your world.
This app also exists to show that nias3 can cope with data that it has never seen before -  no lesson sequences are included in the data fed into the system by the load process, they only come into being when they are saved within this demo application.
However having saved some you will find them browsable and useable within the GraphQL environment, and in later demos you will see that they have also been linked to student, teacher and school data automatically.

## digital-classroom dynamic view

demo url:

> http://localhost:8003

Dynamic here means putting the same data that we've captured in various ways to use in the classroom.
We've fed data of different types into n3 by loading (publishing) it with the load tool - which simply publishes files by posting them to n3w, and we (may) have added some more data by using a connected system such as the lesson planner.

The dynamic view now allows us to get more value from those sets of data by bringing them together through the use of graph traversals.

In the demo app you can select one of teachers from our school (SIF StaffPersonal data), which will then show the weekly schedule of lessons for that teacher (SIF TeachingGroup, SIF Timetable).
Selecting a lesson will then show the assessment results of those students across four assessment events - those results are xapi data, but they are now being automatically linked to SIF TeachingGroup and SIF GradingAssignment data.
Finally clicking on a row of the results table will show the score a student received, which is pure xAPI data, but also the absence days for that student, linking back to SIF Attendance records.

## multi-model 2


demo url:
> http://localhost:1323/mm2/
 
 This last demo takes the previous one step further, now when you select a student in the results table (for the subjects History or Geography), not just do we have the links between SIF and xAPI, we also can show the syllabus outcomes for the student, and (if you created lessons in the lesson-planner) their attendance at those lessons.
 So automatically inking between two different sets of structured data SIF and xAPI, and linking multiple arbitrary data sets created by bespoke applications.

## Components


If you want to look at underlying code, the pieces of nias3 can be found in the following repositories, all of which are open source and Apache 2.0 Licenced.

+ [n3-deep6](https://github.com/nsip/n3-deep6) our hexastore-with-linking database
+ [n3-web](https://github.com/nsip/n3-web) the web server to which you can publish and query data, and which publishes data across the network of connected nodes
+ [n3-context](https://github.com/nsip/n3-context) if you want to run a distributed set of nodes, context is the 'unit-of-data-sharing' you decide within a context who you will allow to read and write data.
+ [n3-gql](https://github.com/nsip/n3-gql) handles the graphql implementation - builds schemas dynamically from the data published to the system.
+ [n3-crdt](https://github.com/nsip/n3-crdt) if you do want to run the system as distributed synchronising nodes, the this layer ensures all data is consistent across the network.
+ [dc-ui](https://github.com/nsip/DC-UI) the javascript application for the lesson-planner demo. Is a Vue/Quasar application, so those frameworks will be needed to work with it
+ [dc-dynamic](https://github.com/nsip/dc-dynamic) this is the 'daybook' demo application. Again Vue/Quasar.
+ [mm1/mm2](https://github.com/nsip/n3-web/tree/master/server/n3w/public) these are very simple / plain html + jQuery demos, so are actually in the n3-web project itself.

We also have a key dependency on [nats](https://github.com/nats-io) for message brokering and streaming services, and our datastore is built on top of [badger](https://github.com/dgraph-io/badger).
Both of these are really outstanding projects, and made much of what we're trying to do here possible.

 We have a great deal more to document, such as using the graphql interface, the query language, the other tools, please bear with us as we add more to this site in the coming weeks....



## Build Requirements

* go version >= 1.12
* git
* node / npm


## Versioning

Versioning system throughout follow this convention

n.n.n

where n is an integer incremented by 1 for each version/build on the following pattern: major.minor.build

For example if the release number is

1.7.12

then 1 is the major release number, 7 is the minor release number, and 12 is the build number.

The release version number consists only of the first two numbers (in our example 1.7)


