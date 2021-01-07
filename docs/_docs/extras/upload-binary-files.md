---
title: 'Upload Binary Files: Images, Attachments, Etc'
---

Jets supports the ability to upload files like images via [Binary Support](https://aws.amazon.com/about-aws/whats-new/2016/11/binary-data-now-supported-by-api-gateway/).  Binary support is enabled for `multipart/form-data` data.  Jets converts the uploaded data from a standard HTML file input field and passes it to your controller as a file object through the `params` helper.

## Example

Here's an example form with an HTML file input field:

```html
<%= form_tag(action, multipart: true) do %>
  <div class="field">
    <%= label_tag :photo %>
    <%= file_field_tag "post[photo]" %>
  </div>
...
```

NOTE: It is important to have `multipart: true` and also remove any `<input type="hidden" name="_method" value="put" />` from the form to ensure the data gets passed from the form correctly to API Gateway.

When the user submits the form, the controller will receive a `params` containing the file upload as an File like object.  Here's an example `params` payload:

```
"post":{"photo":{"filename":"jets.png","type":"image/png","name":"post[photo]","tempfile":"#<File:0x00007fc4d860d7c8>"
```

You can use `params[:post][:photo]` in the controller to read the file and save it to where you need, say s3.

This blog tutorial provides an example of image uploading with Jets and Carrierwave: [Image Upload Carrierwave Tutorial](https://blog.boltops.com/2018/12/13/jets-image-upload-carrierwave-tutorial-binary-support).

