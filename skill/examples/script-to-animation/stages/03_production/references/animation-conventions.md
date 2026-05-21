# Animation Conventions

Last updated: 2026-05-01

---

## Purpose

Defines the visual conventions, component library, colour palette, and Remotion patterns for all animations produced in Stage 03. Use only what is defined here. Do not invent new component types or visual styles — propose them to the human first.

---

## Colour palette

| Name | Hex | Use |
|------|-----|-----|
| Background | `#0F0F0F` | All scene backgrounds |
| Primary text | `#F5F5F5` | Main spoken content on screen |
| Accent | `#6366F1` | Highlights, key terms, underlines |
| Secondary text | `#9CA3AF` | Supporting labels, captions |
| Warning | `#F59E0B` | Used only to flag errors in spec — not for visual output |

---

## Typography

- **Body text (spoken lines on screen):** Inter, 28px, weight 400, line-height 1.5
- **Key terms (highlighted):** Inter, 28px, weight 600, colour Accent
- **Scene labels (not spoken — for review only):** Inter, 14px, weight 400, colour Secondary text, opacity 0.5
- No font sizes outside this list without explicit approval

---

## Component library

### `<TextReveal>`
Reveals text word by word. Used for spoken lines that appear progressively.

```tsx
<TextReveal
  text="The spoken line goes here."
  startFrame={0}
  durationInFrames={90}
  color={colors.primaryText}
/>
```

### `<FadeIn>`
Fades any element in from opacity 0 over a defined duration.

```tsx
<FadeIn durationInFrames={20}>
  <YourElement />
</FadeIn>
```

### `<Highlight>`
Wraps a word or phrase to apply accent colour and bold weight. Used for key terms.

```tsx
<Highlight>key term</Highlight>
```

### `<SceneDivider>`
A visual separator used at scene boundaries. Full-width accent line, 2px, 15-frame fade in/out.

```tsx
<SceneDivider />
```

---

## Scene timing at 30fps

- 1 second = 30 frames
- Use the spec's duration-in-seconds × 30 to calculate `durationInFrames` for each scene component
- Every scene component must declare its `durationInFrames` explicitly — do not rely on default lengths

---

## File structure for Remotion output

```tsx
// topic-name_remotion.tsx

import { Composition } from 'remotion';
import { Scene1Hook } from './scenes/Scene1Hook';
import { Scene2Setup } from './scenes/Scene2Setup';
import { Scene3Explanation } from './scenes/Scene3Explanation';
import { Scene4Close } from './scenes/Scene4Close';

// Each scene is a separate component in a /scenes subfolder
// The Composition stitches them together at their correct offsets
```

Produce one `.tsx` file per scene, plus the root composition file. Name scene files `Scene[N][SceneName].tsx`.

---

## What not to do

- No animations that haven't been defined here (no slides, bounces, or spins unless added to this file)
- No colours outside the palette
- No font sizes outside the defined set
- Do not place more than 25 words of spoken content visible on screen at one time
