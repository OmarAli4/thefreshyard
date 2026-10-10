class ApiConstants {
  static const String shopifyDomain = 'thefreshyard.shop';
  static const String storefrontAccessToken = '687d9c72cad6aa3e012486f4a885f097';
  
  static const String graphqlEndpoint = 'https://$shopifyDomain/api/2024-01/graphql.json';
  static const String corsProxyEndpoint = 'https://corsproxy.io/?$graphqlEndpoint';

  static const String productsQuery = r'''
    query getProducts($first: Int!, $after: String) {
      products(first: $first, after: $after) {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          node {
            id
            title
            description
            images(first: 1) {
              edges {
                node {
                  url(transform: {maxWidth: 600, maxHeight: 600})
                }
              }
            }
            variants(first: 10) {
              edges {
                node {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                }
              }
            }
            rating: metafield(namespace: "reviews", key: "rating") {
              value
            }
            ratingCount: metafield(namespace: "reviews", key: "rating_count") {
              value
            }
          }
        }
      }
    }
  ''';

  static const String customerRecoverMutation = r'''
    mutation customerRecover($email: String!) {
      customerRecover(email: $email) {
        customerUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

  static const String bestSellingProductsQuery = r'''
    query getBestSellingProducts($first: Int!) {
      products(first: $first, sortKey: BEST_SELLING) {
        pageInfo {
          hasNextPage
          endCursor
        }
        edges {
          node {
            id
            title
            description
            images(first: 1) {
              edges {
                node {
                  url(transform: {maxWidth: 600, maxHeight: 600})
                }
              }
            }
            variants(first: 10) {
              edges {
                node {
                  id
                  title
                  price {
                    amount
                    currencyCode
                  }
                  compareAtPrice {
                    amount
                    currencyCode
                  }
                }
              }
            }
            rating: metafield(namespace: "reviews", key: "rating") {
              value
            }
            ratingCount: metafield(namespace: "reviews", key: "rating_count") {
              value
            }
          }
        }
      }
    }
  ''';

  static const String collectionProductsQuery = r'''
    query getCollectionProducts($handle: String!, $first: Int!, $after: String) {
      collection(handle: $handle) {
        title
        products(first: $first, after: $after) {
          pageInfo {
            hasNextPage
            endCursor
          }
          edges {
            node {
              id
              title
              description
              images(first: 1) {
                edges {
                  node {
                    url(transform: {maxWidth: 600, maxHeight: 600})
                  }
                }
              }
              variants(first: 10) {
                edges {
                  node {
                    id
                    title
                    price {
                      amount
                      currencyCode
                    }
                    compareAtPrice {
                      amount
                      currencyCode
                    }
                  }
                }
              }
              rating: metafield(namespace: "reviews", key: "rating") {
                value
              }
              ratingCount: metafield(namespace: "reviews", key: "rating_count") {
                value
              }
            }
          }
        }
      }
    }
  ''';

  static const String collectionsQuery = r'''
    query getCollections($first: Int!) {
      collections(first: $first) {
        edges {
          node {
            id
            title
            handle
            image {
              url
            }
          }
        }
      }
    }
  ''';

  static const String customerAccessTokenCreateMutation = r'''
    mutation customerAccessTokenCreate($input: CustomerAccessTokenCreateInput!) {
      customerAccessTokenCreate(input: $input) {
        customerAccessToken {
          accessToken
          expiresAt
        }
        customerUserErrors {
          code
          field
          message
        }
      }
    }
  ''';

  static const String customerCreateMutation = r'''
    mutation customerCreate($input: CustomerCreateInput!) {
      customerCreate(input: $input) {
        customer {
          id
          firstName
          lastName
          email
        }
        customerUserErrors {
          code
          field
          message
        }
      }
    }
  ''';


  static const String getCustomerProfileQuery = r'''
    query getCustomer($customerAccessToken: String!) {
      customer(customerAccessToken: $customerAccessToken) {
        id
        firstName
        lastName
        email
        phone
        defaultAddress {
          address1
          city
          country
        }
        orders(first: 10) {
          edges {
            node {
              id
              orderNumber
              processedAt
              financialStatus
              fulfillmentStatus
              totalPrice {
                amount
                currencyCode
              }
              lineItems(first: 5) {
                edges {
                  node {
                    title
                    quantity
                  }
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const List<String> checkoutAllowedDomains = [
    'thefreshyard.shop',
    'shopify.com',
    'myshopify.com',
  ];

  static const String cartCreateMutation = r'''
    mutation cartCreate($input: CartInput!) {
      cartCreate(input: $input) {
        cart {
          id
          checkoutUrl
        }
        userErrors {
          code
          field
          message
        }
      }
    }
  ''';
}
