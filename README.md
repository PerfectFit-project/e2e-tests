# PerfectFit virtual coach system main repository
This is a virtual coach system that will coach users into being more physically active and stop smoking.
This is the main repository for running the full application.
Individual components of the app are in separate repositories:
- [virtual-coach-rasa](https://github.com/PerfectFit-project/virtual-coach-rasa) 
Contains code for rasa bot, the core of the virtual coach system.
Also includes `scheduler`, and `onboarding`
- [niceday-components](https://github.com/PerfectFit-project/niceday-components)
Components for interfacing the virtual-coach with the niceday app and sensehealth server.
- [niceday_client](https://github.com/PerfectFit-project/niceday_client)
Python package for interacting with the niceday-api component of the PerfectFit virtual coach.
- [virtual-coach-db](https://github.com/PerfectFit-project/virtual-coach-db)
Code around database for virtual coach system

## Software development planning
See [software development planning document](https://nlesc.sharepoint.com/:w:/r/sites/team-flow/Shared%20Documents/PerfectFit/Perfect%20Fit%20-%20RFCs/PerfectFit-RFC-0007-software-development-planning.docx?d=w434661cbf10c458998e9e45ea6451ea4&csf=1&web=1&e=8cxoLW)

## Architecture design
Take a look at the design [here](docs/design.md).
A representation of the interactions among the components in a conversation flow can be found [here](docs/swimlane.jpg).

## Setting up an account in the NiceDay alpha app
1. Ask any of this project's contributors to request an invitation for installing NiceDay alpha version
2. Download and install the NiceDay alpha version on your phone using the link in the invitation email
3. Open the downloaded app and create a client account. 
This is the account you will use to test functionality in the app and talk to the virtual coach.
It is possible to use the same credentials for both the alpha and normal NiceDay app.
NB: In the creation process, select "I want to use the app independently" when asked.
4. Login to the downloaded app on your phone with the account you just created.
5. Ask any of the project's contributors to provide you with a personal development 'Virtual Test Therapist' account.
The virtual coach system will use this account.
6. Send a connection request to your 'Virtual Test Therapist' account from the app:
Go to the 'support' panel in the app. Click on the '+' symbol at the top right of the panel.
Search for the name of the therapist account you want to connect with. Send a connection request.
7. Login with the therapist account credentials on https://alpha.niceday.app/
and accept the connection request from the client account.

## Setup
1. Create a file called `.env` in the root of this app.
Save the therapist email address and password in your `.env` file as THERAPIST_EMAIL_ADDRESS and THERAPIST_PASSWORD, respectively.
The .env file must also contain `DATABASE_URL`, which points to the location of the perfectfit database on a running postgres server.
For local development this will normally be: `postgresql+psycopg2://root:root@db/perfectfit`
See .env-example for a template. The values in `.env-example` are already set to work for local runs with docker compose (with the exception of THERAPIST_EMAIL_ADDRESS and THERAPIST_PASSWORD, which must be provided).
2. Some of the resources needed to run the application are to be pulled from the GitHub repositories. To allow the pulling, a [SSH key has to be created and added to the ssh-agent](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) 
3. Since the goalie-js repository is private, access to the senseobservationsystems/goalie-js.git repository has to be obtained.

## Run application
Run `script/server` script to serve the application.

NB: If you get a problem about "subdir not supported" during execution of `script/server`, 
set the buildkit feature to false in Docker. 
On Windows, you can do this in Docker Desktop>Settings>Build engine.
On Mac, you can do this in Docker Desktop>Preferences>Docker Engine. Edit the displayed JSON so that `"buildkit": false`, then restart Docker Desktop.

### Configuration
Configure functionality depending on the deployment environment by setting the `ENVIRONMENT` variable in your `.env` file. 
Possible values are ('prod', 'test', 'dev')
This will:
   - toggle whether you want to have a delay in between messages ('prod'), or not ('test', 'dev').

## Test
Run `script/test`, or follow these steps:
1. Run `npm install`
2. Run `script/bootstrap` script
3. Start everything with `docker compose up`.
4. Once all containers are initialised and healthy, run the tests by typing `script/cucumber`

To run a specific feature, add the path to the specific .feature file to the `script/cucumber` script. 
For example, to run the selfdialog feature, the following command has to be used: `./node_modules/.bin/cucumber-js features/selfdialog.feature`

## For developers
By default this setup use the main branch for each component. 
As a developer you often want to use a different branch, or a local clone of the repository.

### Using a local clone docker image:
If you want to use a local clone, we suggest the following steps. 
We use the `virtual-coach-db` repository as an example.
1. Build a docker image based on your local repository. 
`cd` into your local `virtual-coach-db` repository, 
then do `docker build . -t virtual-coach-db-local`.
2. In `docker-compose.yml` replace `build: https://github.com/PerfectFit-project/virtual-coach-db.git#main` 
with `image: virtual-coach-db-local`. 
Note that the name of the image should correspond with the tag that you gave to it in the previous step

NB: Don't commit changes to `docker-compose.yml`

### Pointing to a different branch:
Alternatively you can point `docker-compose` to a different branch:
In `docker-compose.yml` replace `build: https://github.com/PerfectFit-project/virtual-coach-db.git#main` 
with `build: https://github.com/PerfectFit-project/virtual-coach-db.git#feature-branch`.

NB: Don't commit changes to `docker-compose.yml`

### Rebuilding docker images:
If you want to rebuild the images that docker-compose uses 
(often you want this, because you want the latest changes to take effect), run:
`docker compose up --build`

If you want to completely make sure that all docker images are rebuilt without cache, and the database will be reinitialized, do:
```
docker compose down --volumes && docker compose build --no-cache && docker compose up
```


### Database
Test data is automatically loaded into the database using a script in 
`virtual-coach-db` [helper/populate_db.py](https://github.com/PerfectFit-project/virtual-coach-db/blob/ca6b5c79064c3b1dcf34ce83d1f59773f33427e3/helper/populate_db.py).
So if you want to test with different data (particularly if you have updated the db schema by changing `models.py`) you have to update this.
Or spin up the database and manipulate the data in the running database.

NB: The database is saved automatically by docker. To empty the volume that stores the database do:
```
docker compose down --volumes
```
Next time you run the application the database will be reinitialized.
