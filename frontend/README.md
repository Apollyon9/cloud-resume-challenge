# Frontend Technical Specification

- Create a static website that serves an HTML resume.
- I am implementing an incremental approach defined by the instructor to minimize complexity and maximize learning.

---

To accelerate the initial step, I leveraged GenAI to generate the boilerplate HTML and basic CSS.
* **Tool Used:** [Microsoft Copilot]
* **Prompt:** `Convert this resume format into html. Please don't use a css framework. Please use the least amount of css tags`
* **Generated Output:** The initial output is stored in `./docs/Nov-26-2025-raw-resume-output.html` and will be manually refactored.

---

## Technical and Structural Adjustments

The following standardization decisions were made to align with modern web best practices and the overall project goals:

* **File Structure:** Created `docs` (for raw output) and `public` (for final production files) within the frontend directory.
* **Semantic Structure:** For the upcoming refactor, the content will be structured using semantic HTML tags: `<header>`, `<main>`, and `<section>` to ensure clarity and accessibility 

[Images of semantic HTML tags]
.
* **Code Standards:** Using UTF-8, adding the `viewport` meta tag for mobile scaling, and standardizing on **two-space soft tabs**.

---