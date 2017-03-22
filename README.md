# How to use Paperclip with a Rails app and form_tag

## Installing Paperclip
[ImageMagick](http://www.imagemagick.org/) must be installed and Paperclip must have access to it. To install ImageMagick on MacOS with homebrew, run the following command:

```brew install imagemagick```

Install the Paperclip gem in your existing Rails app:

```gem "paperclip", "~> 5.0.0"```

(Or check the [Paperclip docs](https://github.com/thoughtbot/paperclip#installation) for the newest version of the gem.)

Bundle your gem file, and restart your rails server if it is currently running.

```bundle install```

## Create a controller

If you haven't yet, create a photos controller.

```rails g controller photos```

## Adding the image attribute to a model.
If you haven't yet, create a new model where you want to upload the image to, such as a Photo model. Do *not* put the image attribute in yet.

```rails g model Photo title:string```

If you already have the image attribute, you should run a migration to remove it. 

After everything... migrate:

```rake db:migrate```

Now we can use a handy Paperclip generator to add the image attribute to our Photo model:

```rails generate paperclip photo image```

This will create a new migration file that will look something like this:

```
# 20170216195856_add_attachment_image_to_photos.rb

class AddAttachmentImageToPhotos < ActiveRecord::Migration
  def self.up
    change_table :photos do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :photos, :image
  end
end
```

And of course, migrate again.

```rake db:migrate```

Lastly, we need to tell our model that the image attribute will have attachments. Your model should now look something like this:

```
class Photo < ApplicationRecord
  has_attached_file :image
  validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

end
```

The first line is telling your model that the `image` attribute has an attached file. The second line validates the attachment and makes sure that it is actually an image. Feel free to edit the content_type for any other images you may want to add.

## Updating the Form

The following is what the form on your `new` page will look like

```
# /photos/new.html.erb

<h1>Upload Photo</h1>

<%= form_tag "/photos", method: :post, multipart: true do %>

  <div>
    <%= label_tag :title %>
    <%= text_field_tag :title %>
  </div>

  <div>
    <%= label_tag :image %>
    <%= file_field_tag :image %>
  </div>

  <%= submit_tag 'Upload' %>
<% end %>
```

It looks the same as a normal form_tag form, but with two exceptions.

First, you must add the special field `file_field` for the image. When you load the new form, you will see a field where you can upload an image from your computer!

Second, you must add `multipart: true` into the form_tag. This assures that Rails knows that you have a file to upload.

## Updating the controller

Your controller will look something like this:
```
class PhotosController < ApplicationController
  # index and new actions

  def create
    @photo = Photo.new(title: params[:title], image: params[:image])
    if @photo.save
      flash[:success] = "The photo was added!"
      redirect_to photos_path
    else
      render :new
    end
  end

end
```

The controller looks the same as any other controller would. Basically, save whatever params you are passing through.

## Displaying the images

The easiest way to display each image is to use `image_tag`, which is a Rails helper that helps display the image. It's the equivalent of doing `<img src="" />` except you won't need to try and figure out the path back to the image. `image_tag` does that for you!

So for example, in a show page with an `@photo` variable, you should have the following in your show page:

```<%= image_tag(@photo.image.url) %>```

That will display the image. The `image.url` is a [Paperclip method](http://www.rubydoc.info/gems/paperclip/Paperclip/ClassMethods).

And that's about it! For now, these images get stored in your `public` folder. For a production app, it would be better to have these stored in AWS or another server.

# Uploading to AWS

[AWS (Amazon Web Services)](https://console.aws.amazon.com/console/home) is a secure cloud services platform that you can use in conjunction with your app. When you first sign up, you are eligible to use free tier services for your first year, which means that as long as you're not doing anything crazy, you can play around with AWS for free!

So before you do anything, sign up for an AWS account.

## S3 Bucket

We're going to be using S3 Buckets to store the images. You can create a new bucket for every project/app that you create.

To create a new bucket, go into your AWS console and select "S3". There should be a button to create a new bucket. Click the button and start creating your bucket.

You can name your bucket whatever you liked (I named mine acltc-paperclip-s3). Bucket names are unique, so if you wanted to name your bucket 'purple-hippo' but someone already named theirs that, you cannot also name it 'purple-hippo'. 

You can also select your region, which is the endpoint for your server. Ideally you'd pick a region closest to where you currently live to reduce data latency. More information can be found on the [AWS Region and Endpoints](https://docs.aws.amazon.com/general/latest/gr/rande.html) page. 

You can leave the other settings as default.

## Secret Access Key

You will need an access key later on to configure AWS. AWS has a [great tutorial](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) about this, so I will skip this section and refer you to their docs.

## Configuring your app with AWS

The first thing we have to do is add a new gem to our app to allow us to access AWS. Add:

```gem 'aws-sdk', '~> 2.3'```

into your gem file. Don't forget to bundle install!

## Configuring Your Environment

Now you need to configure your environment to add in Paperclip configurations. For the sake of my example I'm only working on development so I will only update my `development.rb` file, but when I push up to production I will also want to add code to my `production.rb`file. Both of these files can be found under `config/environments`.

Somewhere in your file you will want to add the following code:

```
  config.paperclip_defaults = {
    storage: :s3,
    s3_host_name: ENV['AWS_HOST_NAME'],
    s3_credentials: {
      bucket: ENV['S3_BUCKET_NAME'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      s3_region: ENV['AWS_REGION'],
    }
  }
```

Here I'm using environmental variables to keep things such as my secret access key a, well, secret. I personally use ['dot-env gem'](https://github.com/bkeepers/dotenv) to store these in development, but feel free to use whatever you like.

The environmental variables should be self-explanatory from their name except for the host_name. The important thing to note about the host name is that it should be configured like this:

`s3-us-west-1.amazonaws.com`

And replace `us-west-1` with your region.

To compare, my ENV variables look something like this:

```
S3_BUCKET_NAME=acltc-paperclip-s3
AWS_ACCESS_KEY_ID=insert-your-access-key-here
AWS_SECRET_ACCESS_KEY=insert-secret-access-key-here
AWS_REGION=us-west-1
AWS_HOST_NAME=s3-us-west-1.amazonaws.com
```

If you were running your rails server, be sure to restart it before testing. Now everything should work out and it will no longer upload the images into your public folder, but straight to your S3 bucket!
