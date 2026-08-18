class ApiConstants {
  static const String shopifyDomain = 'thefreshyard.shop';
  static const String storefrontAccessToken = '687d9c72cad6aa3e012486f4a885f097';
  
  static const String graphqlEndpoint = 'https://$shopifyDomain/api/2024-01/graphql.json';
  static const String corsProxyEndpoint = 'https://corsproxy.io/?$graphqlEndpoint';

  static const String productsQuery = r'''
    query getProducts($first: Int!) {
      products(first: $first) {
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
                  url(transform: {maxWidth: 400, maxHeight: 400})
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
                }
              }
            }
          }
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
                  url(transform: {maxWidth: 400, maxHeight: 400})
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
                }
              }
            }
          }
        }
      }
    }
  ''';

  static const String collectionProductsQuery = r'''
    query getCollectionProducts($handle: String!, $first: Int!) {
      collection(handle: $handle) {
        title
        products(first: $first) {
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
                    url(transform: {maxWidth: 400, maxHeight: 400})
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
                  }
                }
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
