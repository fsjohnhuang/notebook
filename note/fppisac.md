# Functional Programmming Pattern in Scala and Clojure

## OOP - Builder pattern
for Immutable Object

HttpResponse.java
```
public class HttpResponse{
  private final String body;
  private final Integer responseCode;

  private HttpResponse(Builder builder){
    this.body = builder.body;
    this.responseCode = builder.responseCode;
  }

  public static class Builder{
    private String body;
    private Integer responseCode;

    public static Builder newBuilder(){
      return new Builder();
    }
    public Builder body(String body){
      this.body = body;
      return this
    }
    public Builder responseCode(Integer responseCode){
      this.responseCode = responseCode;
      return this
    }
    public HttpResponse build(){
      return new HttpResponse(this);
    }
  }
}
// Usage
HttpResponse resp = HttpResponse.Builder.newBuilder()
                      .body("something like that.")
                      .responseCode(200)
                      .build();
```
HttpRequest.java
```
public class HttpRequest{
  
}
```
