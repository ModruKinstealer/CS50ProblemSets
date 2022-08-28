window.onload=function(){
  //Get the back to top button
  let mybutton = document.getElementById("btn-back-to-top");

  // When the user scrolls down 20px from the top of the document, show the button
  window.onscroll = function () {
  scrollFunction();
  };

  function scrollFunction() {
  if (
  document.body.scrollTop > 20 ||
  document.documentElement.scrollTop > 20
  ) {
  mybutton.style.display = "block";
  } else {
  mybutton.style.display = "none";
  }
  }
  // When the user clicks on the button, scroll to the top of the document
  mybutton.addEventListener("click", backToTop);

  function backToTop() {
  document.body.scrollTop = 0;
  document.documentElement.scrollTop = 0;
  }

}

function revealContent(event, id) {
  // Declare all variables
  var i, tabcontent, tablinks;

  // Get all elements with class="tabcontent" and hide them
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
    tabcontent[i].style.display = "none";
  }

  // Get all elements with class="tablinks" and remove the class "active"
  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
    tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  // Show the current tab, and add an "active" class to the link that opened the tab
  document.getElementById(id).style.display = "block";
  event.currentTarget.className += " active";
}
