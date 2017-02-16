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