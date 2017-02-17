# How to use Paperclip with a Rails app and form_tag

## Installing Paperclip
1. [ImageMagick](http://www.imagemagick.org/) must be installed and Paperclip must have access to it. To install ImageMagick on MacOS with homebrew, run the following command:

```brew install imagemagick```

2. Install the Paperclip gem in your existing Rails app:

```gem "paperclip", "~> 5.0.0"```

(Or check the [Paperclip docs](https://github.com/thoughtbot/paperclip#installation) for the newest version of the gem.)

3. Bundle your gem file, and restart your rails server if it is currently running.

```bundle install```

## Adding the image attribute to a model.
If you haven't yet, create a new model where you want to upload the image to, such as a Photo model. Do *not* put the image attribute in yet.

```rails g model Photo title:string```

Migrate:

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
    @photo = Photo.new(photo_params)
    if @photo.save
      flash[:success] = "The photo was added!"
      redirect_to photos_path
    else
      render :new
    end
  end

  private

  def photo_params
    params.permit(:image, :title)
  end
end
```

Here we're taking advantage of strong parameters to assure that only the image and title attributes save to the database, but otherwise the controller looks the same as any other controller would.

## Displaying the images

The easiest way to display each image is to use `image_tag`, which is a Rails helper that helps display the image. It's the equivalent of doing `<img src="" />` except you won't need to try and figure out the path back to the image. `image_tag` does that for you!

So for example, in a show page with an `@photo` variable, you should have the following in your show page:

```<%= image_tag(@photo.image.url) %>```

That will display the image. The `image.url` is a [Paperclip method](http://www.rubydoc.info/gems/paperclip/Paperclip/ClassMethods).

And that's about it! For now, these images get stored in your `public` folder. For a production app, it would be better to have these stored in AWS or another server. I will update this guide with information about that in the future, or you can look up other tutorials for that.