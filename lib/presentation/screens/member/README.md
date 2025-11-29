# Member Meal Plans Feature

This feature allows nutritionists to create meal plans for members, which then appear in the member's account.

## How It Works

1. **Nutritionist creates a meal plan**:
   - Nutritionist selects a client from their client list
   - Nutritionist fills in plan details (name, duration, description)
   - Nutritionist specifies daily meals (breakfast, lunch, dinner, snacks)
   - Plan is saved to Firestore with the member's client ID

2. **Member views their meal plans**:
   - Member navigates to the "Meal Plans" tab in their home screen
   - System fetches all meal plans where the client ID matches the member's ID
   - Plans are displayed in a user-friendly card format

## Data Flow

```
Nutritionist Creates Plan → Saved to Firestore → Member Fetches Plans → Displayed in UI
```

## Key Components

### Models
- `MealPlan` model in `nutritionist_models.dart` stores plan data

### Providers
- `NutritionistProvider` handles saving meal plans
- `MemberProvider` handles fetching meal plans for members

### Screens
- `MemberMealPlansScreen` displays meal plans to members
- `CreateEditPlanScreen` allows nutritionists to create/edit plans

## Firestore Structure

```
meal_plans/
  - plan_id/
    - mid: string (plan ID)
    - nutritionistId: string (nutritionist's user ID)
    - clientId: string (member's user ID)
    - name: string (plan name)
    - clientName: string (member's name)
    - duration: string (plan duration)
    - description: string (plan description)
    - createdAt: timestamp (creation date)
    - dailyMeals: map (breakfast, lunch, dinner, snacks)
```

## Testing

The feature includes unit and integration tests to ensure:
- Meal plans are correctly saved with client IDs
- Members can fetch only their assigned plans
- Data structure is maintained correctly