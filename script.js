// ================= Part 1: Variable declarations and conditionals =================
let name = "Terry";
let age = 20;

if (age >= 18) {
  console.log(`${name} is an adult.`);
} else {
  console.log(`${name} is not an adult.`);
}

// ================= Part 2: Custom functions =================
function greet(userName) {
  console.log(`Hello, ${userName}! Welcome to the site.`);
}

function sum(a, b) {
  return a + b;
}

// Using the functions
greet(name);
console.log("Sum of 5 and 10:", sum(5, 10));

// ================= Part 3: Loops =================
// 1. For loop
for (let i = 0; i < 5; i++) {
  console.log("For loop iteration:", i);
}

// 2. While loop
let count = 0;
while (count < 3) {
  console.log("While loop iteration:", count);
  count++;
}

// ================= Part 4: DOM interactions =================
const example1 = document.getElementById("dom-example-1");
example1.textContent = "DOM content changed!";

const example2 = document.getElementById("dom-example-2");
example2.style.color = "blue";

const actionBtn = document.getElementById("actionBtn");
actionBtn.addEventListener("click", function() {
  alert("Button clicked!");
});

// Example 3: Add a new element dynamically
const example3 = document.getElementById("dom-example-3");
const newParagraph = document.createElement("p");
newParagraph.textContent = "This is dynamically added via JS.";
example3.appendChild(newParagraph);
