// Smooth scroll for buttons/links that use data-scroll or hash links
function smoothScrollTo(target) {
  const el =
    typeof target === "string"
      ? document.querySelector(target)
      : target;
  if (!el) return;
  const y = el.getBoundingClientRect().top + window.scrollY - 72; // offset for header
  window.scrollTo({ top: y, behavior: "smooth" });
}

document.addEventListener("click", (event) => {
  const btn = event.target.closest("[data-scroll]");
  if (btn) {
    const selector = btn.getAttribute("data-scroll");
    if (selector) {
      event.preventDefault();
      smoothScrollTo(selector);
    }
  }
  const link = event.target.closest("a[href^='#']");
  if (link && link.getAttribute("href") !== "#") {
    const selector = link.getAttribute("href");
    if (selector && selector.length > 1) {
      const target = document.querySelector(selector);
      if (target) {
        event.preventDefault();
        smoothScrollTo(target);
      }
    }
  }
});

// Contact form fake submission (front-end only)
const form = document.getElementById("contact-form");
const note = document.getElementById("form-note");

if (form && note) {
  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const name = /** @type {HTMLInputElement | null} */ (
      document.getElementById("name")
    );
    note.textContent = name?.value
      ? `Thanks, ${name.value}! This is a demo form only – wire it up to your backend or a form service to receive submissions.`
      : "Thanks! This is a demo form only – wire it up to your backend or a form service to receive submissions.";
  });
}

// Dynamic year in footer
const yearEl = document.getElementById("year");
if (yearEl) {
  yearEl.textContent = String(new Date().getFullYear());
}

